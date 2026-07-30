const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn c_string_ptr(slice: []const u8) [*]const u8 {
    return slice.ptr;
}

// pub fn c_read_file(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
//     const path_c = try allocator.dupeZ(u8, path);
//     defer allocator.free(path_c);
//
//     const file_opt = engine.stdio.fopen(path_c.ptr, "rb");
//     if (file_opt == null) {
//         @panic("file not found error");
//     }
//     const file = file_opt.?;
//
//     _ = engine.stdio.fseek(file, 0, 2);
//     const file_size = @as(usize, @intCast(engine.stdio.ftell(file)));
//     _ = engine.stdio.fseek(file, 0, 0);
//
//     const buffer = try allocator.alloc(u8, file_size);
//     errdefer allocator.free(buffer);
//
//     _ = engine.stdio.fread(buffer.ptr, 1, file_size, file);
//     return buffer;
// }

pub fn get_projection_2d(viewport_size: [2]i32) [16]f32 {
    const projection = engine.calculators.matrix16f_orthographic(0, @as(f32, @floatFromInt(viewport_size[0])), @as(f32, @floatFromInt(viewport_size[1])), 0, -1, 1);

    return projection;
}
pub fn get_projection_3d(aspect_ratio: f32) [16]f32 {
    const projection = engine.calculators.matrix16f_perspective(std.math.degreesToRadians(45), aspect_ratio, 0.1, 100);

    return projection;
}
pub fn get_mouse_position_viewport(window_size: [2]i32, viewport_size: [2]i32, mouse_position: [2]i32) [2]i32 {
    return .{
        @divTrunc(mouse_position[0] * viewport_size[0], window_size[0]),
        @divTrunc(mouse_position[1] * viewport_size[1], window_size[1]),
    };
}

pub fn get_size_scaled_2d(size: [2]i32, scale: [2]f32) [2]f32 {
    return .{
        @as(f32, @floatFromInt(size[0])) * scale[0],
        @as(f32, @floatFromInt(size[1])) * scale[1],
    };
}

pub fn get_text_size_scaled(text: []const u8, font_size: [2]i32, scale: [2]f32) [2]f32 {
    const length = @as(f32, @floatFromInt(text.len));

    const size_scaled = get_size_scaled_2d(font_size, scale);

    return .{
        length * size_scaled[0],
        size_scaled[1],
    };
}
pub fn get_text_multiline_size_scaled(
    text: []const u8,
    font_size: [2]i32,
    scale: [2]f32,
) [2]f32 {
    const size_scaled = get_size_scaled_2d(font_size, scale);
    var current_line_width: f32 = 0;
    var size = [2]f32{ 0, 0 };

    if (text.len > 0) {
        size[1] = size_scaled[1];
    }

    for (text) |character| {
        if (character == '\n') {
            if (current_line_width > size[0]) {
                size[0] = current_line_width;
            }

            current_line_width = 0;
            size[1] += size_scaled[1];
        } else {
            current_line_width += size_scaled[0];
        }
    }

    if (current_line_width > size[0]) {
        size[0] = current_line_width;
    }

    return size;
}

pub fn color_from_rgba(red: u8, green: u8, blue: u8, alpha: u8) [4]f32 {
    return [4]f32{
        @as(f32, @floatFromInt(red)) / 255,
        @as(f32, @floatFromInt(green)) / 255,
        @as(f32, @floatFromInt(blue)) / 255,
        @as(f32, @floatFromInt(alpha)) / 255,
    };
}
pub fn color_from_hex(hex: []const u8) [4]f32 {
    const clean_hex = if (hex[0] == '#') hex[1..] else hex;

    if (clean_hex.len != 8) {
        @panic("color length error");
    }

    const red = std.fmt.parseInt(u8, clean_hex[0..2], 16) catch {
        @panic("color red error");
    };
    const green = std.fmt.parseInt(u8, clean_hex[2..4], 16) catch {
        @panic("color green error");
    };
    const blue = std.fmt.parseInt(u8, clean_hex[4..6], 16) catch {
        @panic("color blue error");
    };
    const alpha = std.fmt.parseInt(u8, clean_hex[6..8], 16) catch {
        @panic("color alpha error");
    };

    return color_from_rgba(red, green, blue, alpha);
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
