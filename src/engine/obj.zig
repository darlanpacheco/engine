const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn extract_vertices_and_indices_obj(
    allocator: std.mem.Allocator,
    obj_text: []const u8,
    vertices: *std.ArrayListUnmanaged(f32),
    indices: *std.ArrayListUnmanaged(u32),
) void {
    var temp_positions = std.ArrayListUnmanaged([3]f32){ .items = &.{}, .capacity = 0 };
    var temp_normals = std.ArrayListUnmanaged([3]f32){ .items = &.{}, .capacity = 0 };
    var temp_uvs = std.ArrayListUnmanaged([2]f32){ .items = &.{}, .capacity = 0 };
    defer temp_positions.deinit(allocator);
    defer temp_normals.deinit(allocator);
    defer temp_uvs.deinit(allocator);

    var vertex_to_index = std.array_hash_map.Auto([8]u32, u32){};
    defer vertex_to_index.deinit(allocator);

    var next_index: u32 = 0;
    var lines = std.mem.splitAny(u8, obj_text, "\r\n");

    while (lines.next()) |raw_line| {
        const line = std.mem.trim(u8, raw_line, " \t");
        if (line.len == 0 or line[0] == '#') continue;

        var tokens = std.mem.tokenizeScalar(u8, line, ' ');

        const prefix_opt = tokens.next();
        if (prefix_opt == null) continue;
        const prefix = prefix_opt.?;

        if (std.mem.eql(u8, prefix, "v")) {
            var x: f32 = 0.0;
            var y: f32 = 0.0;
            var z: f32 = 0.0;
            if (tokens.next()) |t| {
                x = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            if (tokens.next()) |t| {
                y = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            if (tokens.next()) |t| {
                z = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            temp_positions.append(allocator, .{ x, y, z }) catch {};
        } else if (std.mem.eql(u8, prefix, "vn")) {
            var x: f32 = 0.0;
            var y: f32 = 0.0;
            var z: f32 = 0.0;
            if (tokens.next()) |t| {
                x = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            if (tokens.next()) |t| {
                y = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            if (tokens.next()) |t| {
                z = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            temp_normals.append(allocator, .{ x, y, z }) catch {};
        } else if (std.mem.eql(u8, prefix, "vt")) {
            var u: f32 = 0.0;
            var v: f32 = 0.0;
            if (tokens.next()) |t| {
                u = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            if (tokens.next()) |t| {
                v = std.fmt.parseFloat(f32, t) catch 0.0;
            }
            temp_uvs.append(allocator, .{ u, 1.0 - v }) catch {};
        } else if (std.mem.eql(u8, prefix, "f")) {
            var face_verts: [4][8]f32 = undefined;
            var face_len: usize = 0;

            for (0..4) |_| {
                const trio_opt = tokens.next();
                if (trio_opt == null) break;
                const trio = trio_opt.?;

                var indices_tokens = std.mem.splitScalar(u8, trio, '/');

                var v_index: usize = 0;
                if (indices_tokens.next()) |v_str| {
                    v_index = (std.fmt.parseInt(usize, v_str, 10) catch 1) - 1;
                }

                var vt_index: ?usize = null;
                if (indices_tokens.next()) |v_str| {
                    if (v_str.len > 0) vt_index = (std.fmt.parseInt(usize, v_str, 10) catch 1) - 1;
                }

                var vn_index: ?usize = null;
                if (indices_tokens.next()) |v_str| {
                    if (v_str.len > 0) vn_index = (std.fmt.parseInt(usize, v_str, 10) catch 1) - 1;
                }

                const pos = if (v_index < temp_positions.items.len) temp_positions.items[v_index] else .{ 0.0, 0.0, 0.0 };
                const norm = if (vn_index) |idx| (if (idx < temp_normals.items.len) temp_normals.items[idx] else .{ 0.0, 0.0, 0.0 }) else .{ 0.0, 0.0, 0.0 };
                const uv = if (vt_index) |idx| (if (idx < temp_uvs.items.len) temp_uvs.items[idx] else .{ 0.0, 0.0 }) else .{ 0.0, 0.0 };

                if (face_len < 4) {
                    face_verts[face_len] = .{ pos[0], pos[1], pos[2], norm[0], norm[1], norm[2], uv[0], uv[1] };
                    face_len += 1;
                }
            }

            if (face_len >= 3) {
                const tri1_idx = [3]usize{ 0, 1, 2 };
                for (tri1_idx) |idx| {
                    const f_vertex = face_verts[idx];
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

            if (face_len == 4) {
                const tri2_idx = [3]usize{ 0, 2, 3 };
                for (tri2_idx) |idx| {
                    const f_vertex = face_verts[idx];
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
}
