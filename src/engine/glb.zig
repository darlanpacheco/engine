const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn extract_vertices_and_indices_glb(
    allocator: std.mem.Allocator,
    data: *engine.cgltf.cgltf_data,
    vertices: *std.ArrayListUnmanaged(f32),
    indices: *std.ArrayListUnmanaged(u32),
) void {
    var vertex_to_index = std.array_hash_map.Auto([8]u32, u32){};
    defer vertex_to_index.deinit(allocator);

    var next_index: u32 = 0;

    for (0..data.meshes_count) |mesh_idx| {
        const mesh = &data.meshes[mesh_idx];
        var node_scale: [3]f32 = .{ 1.0, 1.0, 1.0 };

        for (0..data.nodes_count) |node_idx| {
            const node = &data.nodes[node_idx];
            if (node.mesh == mesh) {
                if (node.has_scale != 0) {
                    node_scale[0] = node.scale[0];
                    node_scale[1] = node.scale[1];
                    node_scale[2] = node.scale[2];
                }
                break;
            }
        }

        for (0..mesh.primitives_count) |prim_idx| {
            const primitive = &mesh.primitives[prim_idx];
            if (primitive.attributes_count == 0) continue;

            const has_indices = primitive.indices != null;

            var loop_count: usize = 0;
            if (has_indices) {
                loop_count = primitive.indices.*.count;
            } else {
                loop_count = primitive.attributes[0].data.*.count;
            }

            for (0..loop_count) |i| {
                var real_vertex_idx: usize = 0;
                if (has_indices) {
                    real_vertex_idx = engine.cgltf.cgltf_accessor_read_index(primitive.indices, i);
                } else {
                    real_vertex_idx = i;
                }

                var pos: [3]f32 = .{ 0, 0, 0 };
                var norm: [3]f32 = .{ 0, 0, 1 };
                var uv: [2]f32 = .{ 0, 0 };

                for (0..primitive.attributes_count) |attr_idx| {
                    const attr = &primitive.attributes[attr_idx];

                    if (attr.type == engine.cgltf.cgltf_attribute_type_position) {
                        _ = engine.cgltf.cgltf_accessor_read_float(attr.data, real_vertex_idx, &pos[0], 3);
                    } else if (attr.type == engine.cgltf.cgltf_attribute_type_normal) {
                        _ = engine.cgltf.cgltf_accessor_read_float(attr.data, real_vertex_idx, &norm[0], 3);
                    } else if (attr.type == engine.cgltf.cgltf_attribute_type_texcoord) {
                        _ = engine.cgltf.cgltf_accessor_read_float(attr.data, real_vertex_idx, &uv[0], 2);
                    }
                }

                const f_vertex = [8]f32{
                    pos[0] * node_scale[0],
                    pos[1] * node_scale[1],
                    pos[2] * node_scale[2],
                    norm[0],
                    norm[1],
                    norm[2],
                    uv[0],
                    1.0 - uv[1],
                };

                const key: [8]u32 = @bitCast(f_vertex);
                const geder = vertex_to_index.getOrPut(allocator, key) catch @panic("OOM");

                if (!geder.found_existing) {
                    geder.value_ptr.* = next_index;
                    vertices.appendSlice(allocator, &f_vertex) catch @panic("OOM");
                    next_index += 1;
                }

                indices.append(allocator, geder.value_ptr.*) catch @panic("OOM");
            }
        }
    }
}
