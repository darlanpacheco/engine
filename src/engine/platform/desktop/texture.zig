const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

pub fn texture_new(path: []const u8) struct { u32, [2]i32 } {
    var path_buffer: [256]u8 = undefined;
    const c_path = api.global.c_string(&path_buffer, path);

    var size: [2]i32 = .{ 0, 0 };
    var channels: i32 = 0;
    const maybe_pixels = api.global.image.stbi_load(c_path.ptr, &size[0], &size[1], &channels, 4);
    if (maybe_pixels == null) {
        @panic("image error");
    }

    const pixels = maybe_pixels.?;
    defer api.global.image.stbi_image_free(pixels);
    var id: u32 = 0;
    glfw.glGenTextures(1, &id);
    glfw.glBindTexture(glfw.GL_TEXTURE_2D, id);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_WRAP_S, glfw.GL_REPEAT);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_WRAP_T, glfw.GL_REPEAT);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_MIN_FILTER, glfw.GL_NEAREST);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_MAG_FILTER, glfw.GL_NEAREST);
    glfw.glTexImage2D(
        glfw.GL_TEXTURE_2D,
        0,
        glfw.GL_SRGB8_ALPHA8,
        size[0],
        size[1],
        0,
        glfw.GL_RGBA,
        glfw.GL_UNSIGNED_BYTE,
        pixels,
    );

    glfw.glBindTexture(glfw.GL_TEXTURE_2D, 0);

    std.debug.print("texture new: [{any}], [{d}, {d}]\n", .{ id, size[0], size[1] });

    return .{ id, size };
}
pub fn texture_glb_new(path: []const u8) struct { u32, [2]i32 } {
    var path_buffer: [256]u8 = undefined;
    const c_path = api.global.c_string(&path_buffer, path);

    var options = std.mem.zeroes(api.cgltf.cgltf_options);
    var data: *api.cgltf.cgltf_data = undefined;

    if (api.cgltf.cgltf_parse_file(&options, c_path.ptr, @ptrCast(&data)) != api.cgltf.cgltf_result_success) {
        @panic("GLB parser error");
    }
    defer api.cgltf.cgltf_free(data);

    if (api.cgltf.cgltf_load_buffers(&options, data, c_path.ptr) != api.cgltf.cgltf_result_success) {
        @panic("GLB buffers error");
    }

    if (data.images_count == 0) {
        @panic("GLB texture error");
    }

    const img = &data.images[0];
    const view = img.buffer_view.?;
    const buffer_start = @as([*]const u8, @ptrCast(view.*.buffer.*.data)) + view.*.offset;
    const buffer_size = view.*.size;

    var size: [2]i32 = .{ 0, 0 };
    var channels: i32 = 0;

    const maybe_pixels = api.global.image.stbi_load_from_memory(
        buffer_start,
        @intCast(buffer_size),
        &size[0],
        &size[1],
        &channels,
        4,
    );

    if (maybe_pixels == null) {
        @panic("image decoding error");
    }

    const pixels = maybe_pixels.?;
    defer api.global.image.stbi_image_free(pixels);

    var id: u32 = 0;
    glfw.glGenTextures(1, &id);
    glfw.glBindTexture(glfw.GL_TEXTURE_2D, id);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_WRAP_S, glfw.GL_REPEAT);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_WRAP_T, glfw.GL_REPEAT);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_MIN_FILTER, glfw.GL_NEAREST);
    glfw.glTexParameteri(glfw.GL_TEXTURE_2D, glfw.GL_TEXTURE_MAG_FILTER, glfw.GL_NEAREST);

    glfw.glTexImage2D(
        glfw.GL_TEXTURE_2D,
        0,
        glfw.GL_SRGB8_ALPHA8,
        size[0],
        size[1],
        0,
        glfw.GL_RGBA,
        glfw.GL_UNSIGNED_BYTE,
        pixels,
    );

    glfw.glBindTexture(glfw.GL_TEXTURE_2D, 0);

    return .{ id, size };
}
pub fn texture_delete(texture: u32) void {
    _ = texture;

    @panic("texture delete error");
}

pub fn active_texture(texture: u32) void {
    glfw.glActiveTexture(glfw.GL_TEXTURE0);
    glfw.glBindTexture(glfw.GL_TEXTURE_2D, texture);
}
