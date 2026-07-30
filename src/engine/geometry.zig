const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

fn quad_data_new(size: [2]f32) struct { [32]f32, [6]u32 } {
    const size_mid = .{ size[0] / 2, size[1] / 2 };

    const vertices = [32]f32{
        // X, Y, Z, NX, NY, NZ, U, V
        -size_mid[0], -size_mid[1], 0, 0, 0, 1, 0, 0,
        size_mid[0],  -size_mid[1], 0, 0, 0, 1, 1, 0,
        size_mid[0],  size_mid[1],  0, 0, 0, 1, 1, 1,
        -size_mid[0], size_mid[1],  0, 0, 0, 1, 0, 1,
    };

    const indices = [6]u32{
        0, 1, 2,
        2, 3, 0,
    };

    return .{ vertices, indices };
}
pub fn quad_new(size: [2]f32) struct { u32, u32, u32, [32]f32, [6]u32 } {
    const vertices, const indices = quad_data_new(size);
    const vao, const vbo, const ebo = api.gpu.geometry_new(&vertices, &indices);

    return .{ vao, vbo, ebo, vertices, indices };
}

fn cube_data_new(size: [3]f32) struct { [192]f32, [36]u32 } {
    const size_mid = .{ size[0] / 2, size[1] / 2, size[2] / 2 };

    const vertices = [192]f32{
        // X, Y, Z, NX, NY, NZ, U, V
        -size_mid[0], -size_mid[1], size_mid[2],  0,  0,  1,  0, 0,
        size_mid[0],  -size_mid[1], size_mid[2],  0,  0,  1,  1, 0,
        size_mid[0],  size_mid[1],  size_mid[2],  0,  0,  1,  1, 1,
        -size_mid[0], size_mid[1],  size_mid[2],  0,  0,  1,  0, 1,

        -size_mid[0], -size_mid[1], -size_mid[2], 0,  0,  -1, 1, 0,
        size_mid[0],  -size_mid[1], -size_mid[2], 0,  0,  -1, 0, 0,
        size_mid[0],  size_mid[1],  -size_mid[2], 0,  0,  -1, 0, 1,
        -size_mid[0], size_mid[1],  -size_mid[2], 0,  0,  -1, 1, 1,

        -size_mid[0], size_mid[1],  size_mid[2],  -1, 0,  0,  1, 1,
        -size_mid[0], size_mid[1],  -size_mid[2], -1, 0,  0,  0, 1,
        -size_mid[0], -size_mid[1], -size_mid[2], -1, 0,  0,  0, 0,
        -size_mid[0], -size_mid[1], size_mid[2],  -1, 0,  0,  1, 0,

        size_mid[0],  size_mid[1],  size_mid[2],  1,  0,  0,  0, 1,
        size_mid[0],  size_mid[1],  -size_mid[2], 1,  0,  0,  1, 1,
        size_mid[0],  -size_mid[1], -size_mid[2], 1,  0,  0,  1, 0,
        size_mid[0],  -size_mid[1], size_mid[2],  1,  0,  0,  0, 0,

        -size_mid[0], size_mid[1],  -size_mid[2], 0,  1,  0,  0, 1,
        size_mid[0],  size_mid[1],  -size_mid[2], 0,  1,  0,  1, 1,
        size_mid[0],  size_mid[1],  size_mid[2],  0,  1,  0,  1, 0,
        -size_mid[0], size_mid[1],  size_mid[2],  0,  1,  0,  0, 0,

        -size_mid[0], -size_mid[1], -size_mid[2], 0,  -1, 0,  1, 1,
        size_mid[0],  -size_mid[1], -size_mid[2], 0,  -1, 0,  0, 1,
        size_mid[0],  -size_mid[1], size_mid[2],  0,  -1, 0,  0, 0,
        -size_mid[0], -size_mid[1], size_mid[2],  0,  -1, 0,  1, 0,
    };

    const indices = [36]u32{
        0,  1,  2,  2,  3,  0,
        4,  5,  6,  6,  7,  4,
        8,  9,  10, 10, 11, 8,
        12, 13, 14, 14, 15, 12,
        16, 17, 18, 18, 19, 16,
        20, 21, 22, 22, 23, 20,
    };

    return .{ vertices, indices };
}
pub fn cube_new(size: [3]f32) struct { u32, u32, u32, [192]f32, [36]u32 } {
    const vertices, const indices = cube_data_new(size);
    const vao, const vbo, const ebo = api.gpu.geometry_new(&vertices, &indices);

    return .{ vao, vbo, ebo, vertices, indices };
}

fn obj_data_new(path: []const u8, allocator: std.mem.Allocator) struct { []f32, []u32 } {
    const obj_text = engine.global.c_read_file(allocator, path) catch {
        @panic("obj error");
    };
    defer allocator.free(obj_text);

    var vertices_list = std.ArrayListUnmanaged(f32){ .items = &.{}, .capacity = 0 };
    var indices_list = std.ArrayListUnmanaged(u32){ .items = &.{}, .capacity = 0 };

    engine.obj.extract_vertices_and_indices_obj(allocator, obj_text, &vertices_list, &indices_list);

    const vertices = vertices_list.toOwnedSlice(allocator) catch {
        @panic("out of memory error");
    };
    const indices = indices_list.toOwnedSlice(allocator) catch {
        @panic("out of memory error");
    };

    return .{ vertices, indices };
}
pub fn obj_new(path: []const u8, allocator: std.mem.Allocator) struct { u32, u32, u32, []f32, []u32 } {
    const vertices, const indices = obj_data_new(path, allocator);
    const vao, const vbo, const ebo = api.gpu.geometry_new(vertices, indices);

    // vertices and indices needs to be freed

    return .{ vao, vbo, ebo, vertices, indices };
}

fn glb_data_new(path: []const u8, allocator: std.mem.Allocator) struct { []f32, []u32 } {
    const c_path = allocator.dupeZ(u8, path) catch {
        @panic("out of memory error");
    };
    defer allocator.free(c_path);

    var options = std.mem.zeroes(engine.cgltf.cgltf_options);
    var data: *engine.cgltf.cgltf_data = undefined;

    if (engine.cgltf.cgltf_parse_file(&options, c_path.ptr, @ptrCast(&data)) != engine.cgltf.cgltf_result_success) {
        @panic("GLB parser error");
    }
    defer engine.cgltf.cgltf_free(data);

    if (engine.cgltf.cgltf_load_buffers(&options, data, c_path.ptr) != engine.cgltf.cgltf_result_success) {
        @panic("GLB buffers error");
    }

    var vertices_list = std.ArrayListUnmanaged(f32){ .items = &.{}, .capacity = 0 };
    var indices_list = std.ArrayListUnmanaged(u32){ .items = &.{}, .capacity = 0 };

    engine.glb.extract_vertices_and_indices_glb(allocator, data, &vertices_list, &indices_list);

    const vertices = vertices_list.toOwnedSlice(allocator) catch {
        @panic("out of memory error");
    };
    const indices = indices_list.toOwnedSlice(allocator) catch {
        @panic("out of memory error");
    };

    return .{ vertices, indices };
}
pub fn glb_new(path: []const u8, allocator: std.mem.Allocator) struct { u32, u32, u32, []f32, []u32 } {
    const vertices, const indices = glb_data_new(path, allocator);
    const vao, const vbo, const ebo = api.gpu.geometry_new(vertices, indices);

    // vertices and indices needs to be freed

    return .{ vao, vbo, ebo, vertices, indices };
}
