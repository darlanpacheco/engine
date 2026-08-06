const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn c_string_ptr(slice: []const u8) [*]const u8 {
    return slice.ptr;
}
pub fn c_read_file(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const path_c = try allocator.dupeZ(u8, path);
    defer allocator.free(path_c);

    const file_opt = engine.stdio.fopen(path_c.ptr, "rb");
    if (file_opt == null) {
        @panic("file not found error");
    }
    const file = file_opt.?;

    _ = engine.stdio.fseek(file, 0, 2);
    const file_size = @as(usize, @intCast(engine.stdio.ftell(file)));
    _ = engine.stdio.fseek(file, 0, 0);

    const buffer = try allocator.alloc(u8, file_size);
    errdefer allocator.free(buffer);

    _ = engine.stdio.fread(buffer.ptr, 1, file_size, file);
    return buffer;
}

pub fn get_projection_2d(viewport_size: [2]i32) [16]f32 {
    const projection = engine.calculators.matrix16f_orthographic(0, @as(f32, @floatFromInt(viewport_size[0])), @as(f32, @floatFromInt(viewport_size[1])), 0, -1, 1);

    return projection;
}
pub fn get_projection_3d(aspect_ratio: f32) [16]f32 {
    const projection = engine.calculators.matrix16f_perspective(std.math.degreesToRadians(45), aspect_ratio, 0.1, 100);

    return projection;
}
pub fn get_mouse_position_viewport(window_size: [2]i32, viewport_size: [2]i32, mouse_position: [2]f32) [2]f32 {
    return .{
        (mouse_position[0] * @as(f32, @floatFromInt(viewport_size[0]))) / @as(f32, @floatFromInt(window_size[0])),
        (mouse_position[1] * @as(f32, @floatFromInt(viewport_size[1]))) / @as(f32, @floatFromInt(window_size[1])),
    };
}

pub fn build_shader_source(allocator: std.mem.Allocator, headers: []const []const u8, bodies: []const []const u8) []u8 {
    const prefix = "void main() {\n";
    const suffix = "\n}\n";

    var total_len: usize = prefix.len + suffix.len;
    for (headers) |h| {
        total_len += h.len;
    }
    for (bodies) |b| {
        total_len += b.len;
    }

    const result = allocator.alloc(u8, total_len) catch {
        @panic("shader source building error");
    };

    var offset: usize = 0;

    for (headers) |h| {
        @memcpy(result[offset .. offset + h.len], h);
        offset += h.len;
    }

    @memcpy(result[offset .. offset + prefix.len], prefix);
    offset += prefix.len;

    for (bodies) |b| {
        @memcpy(result[offset .. offset + b.len], b);
        offset += b.len;
    }

    @memcpy(result[offset .. offset + suffix.len], suffix);

    return result;
}
