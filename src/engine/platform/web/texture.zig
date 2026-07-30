const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

extern fn webgl_create_texture() u32;
extern fn webgl_delete_texture(texture: u32) void;
extern fn webgl_tex_image_2d(target: u32, level: i32, internalformat: i32, width: i32, height: i32, border: i32, format: u32, type: u32, ptr: [*]const u8, len: usize) void;
extern fn webgl_tex_parameter_i(target: u32, pname: u32, param: i32) void;
extern fn webgl_generate_mipmap(target: u32) void;

extern fn webgl_active_texture(texture: u32) void;
extern fn webgl_bind_texture(target: u32, texture: u32) void;

//
//
//
//

extern fn engine_image_ready(id: u32) bool;
extern fn engine_image_get(id: u32, width: *i32, height: *i32) ?[*]u8;
extern fn engine_image_request(path: [*:0]const u8) u32;
export fn alloc_pixels(size: usize) [*]u8 {
    const allocator = std.heap.wasm_allocator;
    const slice = allocator.alloc(u8, size) catch @panic("OOM");
    return slice.ptr;
}

//
//
//
//

pub fn image_wait(id: u32) bool {
    return engine_image_ready(id);
}
pub fn image_get(path: []const u8) u32 {
    var buffer: [256]u8 = undefined;
    const c_path = api.global.c_string(&buffer, path);

    return engine_image_request(c_path.ptr);
}
pub fn image_pixels(
    id: u32,
    width: *i32,
    height: *i32,
) ?[*]u8 {
    return engine_image_get(
        id,
        width,
        height,
    );
}
pub fn texture_new(path: []const u8) struct { u32, [2]i32 } {
    const image_id = image_get(path);

    if (!image_wait(image_id)) {
        return .{ 0, .{ 0, 0 } };
    }

    var size: [2]i32 = .{ 0, 0 };

    const pixels = image_pixels(image_id, &size[0], &size[1]).?;

    const id = webgl_create_texture();

    webgl_bind_texture(engine.types.GL_TEXTURE_2D, id);
    webgl_tex_parameter_i(engine.types.GL_TEXTURE_2D, engine.types.GL_TEXTURE_WRAP_S, engine.types.GL_REPEAT);
    webgl_tex_parameter_i(engine.types.GL_TEXTURE_2D, engine.types.GL_TEXTURE_WRAP_T, engine.types.GL_REPEAT);
    webgl_tex_parameter_i(engine.types.GL_TEXTURE_2D, engine.types.GL_TEXTURE_MIN_FILTER, engine.types.GL_NEAREST);
    webgl_tex_parameter_i(engine.types.GL_TEXTURE_2D, engine.types.GL_TEXTURE_MAG_FILTER, engine.types.GL_NEAREST);

    const byte_len = @as(usize, @intCast(size[0] * size[1] * 4));

    webgl_tex_image_2d(engine.types.GL_TEXTURE_2D, 0, engine.types.GL_RGBA, size[0], size[1], 0, engine.types.GL_RGBA, engine.types.GL_UNSIGNED_BYTE, pixels, byte_len);
    webgl_bind_texture(engine.types.GL_TEXTURE_2D, 0);

    return .{ id, size };
}
pub fn texture_delete(texture: u32) void {
    webgl_delete_texture(texture);
}

pub fn active_texture(texture: u32) void {
    webgl_active_texture(engine.types.GL_TEXTURE0);
    webgl_bind_texture(engine.types.GL_TEXTURE_2D, texture);
}
