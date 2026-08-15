const std = @import("std");
const engine = @import("engine");

// const stdio_lib = @cImport({
//     @cInclude("stdio.h");
// });
const glfw_lib = @cImport({
    @cInclude("glad.h");
    @cInclude("glfw3.h");
});
const stb_image_lib = @cImport({
    @cInclude("stb_image.h");
});
const miniaudio_lib = @cImport({
    @cInclude("miniaudio.h");
});
const cgltf_lib = @cImport({
    @cInclude("cgltf.h");
});

pub const glfw = glfw_lib;
pub const image = stb_image_lib;
pub const audio = miniaudio_lib;
pub const gltf = cgltf_lib;
pub const api = *glfw.GLFWwindow;

var last_time: f64 = 0;

pub fn c_string(buffer: []u8, path: []const u8) [:0]const u8 {
    if (path.len >= buffer.len) {
        @panic("buffer error");
    }

    @memcpy(buffer[0..path.len], path);
    buffer[path.len] = 0;

    return buffer[0..path.len :0];
}

pub fn get_delta_time() f32 {
    const current_time = glfw.glfwGetTime();

    if (last_time == 0) {
        last_time = current_time;
        return 0;
    }

    const delta_time = current_time - last_time;
    last_time = current_time;

    return @floatCast(delta_time);
}

pub fn get_monitor_size() [2]i32 {
    const monitor = glfw.glfwGetPrimaryMonitor();
    if (monitor == null) {
        @panic("monitor size error");
    }

    const mode = glfw.glfwGetVideoMode(monitor);

    return .{ mode.*.width, mode.*.height };
}
pub fn get_window_size(window: api) [2]i32 {
    var window_size: [2]c_int = .{ 0, 0 };

    glfw.glfwGetWindowSize(window, &window_size[0], &window_size[1]);

    return .{ @intCast(window_size[0]), @intCast(window_size[1]) };
}

pub fn get_mouse_position(window: api, window_size: [2]i32) [2]f32 {
    var position: [2]f64 = .{ 0, 0 };

    glfw.glfwGetCursorPos(window, &position[0], &position[1]);

    const position_f32 = [2]f32{
        @floatCast(position[0]),
        @floatCast(position[1]),
    };

    return .{
        std.math.clamp(position_f32[0], 0.0, @as(f32, @floatFromInt(window_size[0])) - 1.0),
        std.math.clamp(position_f32[1], 0.0, @as(f32, @floatFromInt(window_size[1])) - 1.0),
    };
}

pub fn get_gamepad_ids() [16]i32 {
    var ids: [16]i32 = undefined;

    for (0..16) |jid| {
        const jid_i32 = @as(i32, @intCast(jid));

        if (glfw.glfwJoystickPresent(jid_i32) == 1) {
            ids[jid] = jid_i32;
        } else {
            ids[jid] = -1;
        }
    }

    return ids;
}

pub fn mouse_disabled(window: api) void {
    glfw.glfwSetInputMode(window, glfw.GLFW_CURSOR, glfw.GLFW_CURSOR_DISABLED);
}

pub fn vsync(value: bool) void {
    if (value) {
        glfw.glfwSwapInterval(1);
    } else {
        glfw.glfwSwapInterval(0);
    }
}
// pub fn fullscreen(window: api, value: bool) void { // REALLY BAD CODE
//     if (value) {
//         if (glfw.glfwGetPrimaryMonitor()) |monitor| {
//             if (glfw.glfwGetVideoMode(monitor)) |mode| {
//                 glfw.glfwSetWindowMonitor(window, monitor, 0, 0, mode.*.width, mode.*.height, mode.*.refreshRate);
//             }
//         }
//     } else {
//         if (glfw.glfwGetPrimaryMonitor()) |monitor| {
//             if (glfw.glfwGetVideoMode(monitor)) |mode| {
//                 const monitor_w = mode.*.width;
//                 const monitor_h = mode.*.height;
//
//                 const win_w = 800;
//                 const win_h = 600;
//
//                 const pos_x = @divTrunc(monitor_w - win_w, 2);
//                 const pos_y = @divTrunc(monitor_h - win_h, 2);
//
//                 glfw.glfwSetWindowMonitor(window, null, pos_x, pos_y, win_w, win_h, 0);
//             }
//         }
//     }
// }

pub fn window_events() void {
    glfw.glfwPollEvents();
}

pub fn get_window_should_close(window: api) bool {
    return glfw.glfwWindowShouldClose(window) == 0;
}
pub fn window_should_close(window: api, value: bool) void {
    if (value) {
        glfw.glfwSetWindowShouldClose(window, engine.types.GLFW_TRUE);
    } else {
        glfw.glfwSetWindowShouldClose(window, engine.types.GLFW_FALSE);
    }
}
