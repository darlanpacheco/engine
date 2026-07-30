const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

extern fn webgl_clear_color(
    r: f32,
    g: f32,
    b: f32,
    a: f32,
) void;

extern fn webgl_clear() void;

//
//
//
//

pub fn start_glfw() void {}

pub fn start(title: []const u8, window_size: [2]i32) void {
    _ = title;
    _ = window_size;
}

pub fn stop() void {}

pub fn draw_start(color: [4]f32) void {
    webgl_clear_color(
        color[0],
        color[1],
        color[2],
        color[3],
    );

    webgl_clear();
}

pub fn draw_viewport(size: [2]i32) void {
    _ = size;
}

pub fn draw_stop() void {}
