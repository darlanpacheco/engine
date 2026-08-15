const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

// REALLY BAD PARAMETERS

extern fn web_get_delta_time() f32;
extern fn web_get_monitor_size(width_ptr: *i32, height_ptr: *i32) void;
extern fn web_get_window_size(width_ptr: *i32, height_ptr: *i32) void;
extern fn web_get_mouse_position(x_ptr: *f64, y_ptr: *f64) void;
extern fn web_get_gamepad_ids(ids_ptr: [*]i32) void;

//
//
//
//

pub fn c_string(buffer: []u8, path: []const u8) [:0]const u8 {
    @memcpy(buffer[0..path.len], path);
    buffer[path.len] = 0;

    return buffer[0..path.len :0];
}

pub fn get_delta_time() f32 {
    return web_get_delta_time();
}

pub fn get_monitor_size() [2]i32 {
    var size: [2]i32 = .{ 0, 0 };

    web_get_monitor_size(&size[0], &size[1]);

    return .{ size[0], size[1] };
}
pub fn get_window_size(window: api.api) [2]i32 {
    _ = window;

    var size: [2]i32 = .{ 0, 0 };

    web_get_window_size(&size[0], &size[1]);

    return .{ size[0], size[1] };
}

pub fn get_mouse_position(window: api.api, window_size: [2]i32) [2]f32 {
    _ = window;

    var position: [2]f64 = .{ 0, 0 };
    web_get_mouse_position(&position[0], &position[1]);

    return .{
        std.math.clamp(@as(f32, @floatCast(position[0])), 0.0, @as(f32, @floatFromInt(window_size[0])) - 1.0),
        std.math.clamp(@as(f32, @floatCast(position[1])), 0.0, @as(f32, @floatFromInt(window_size[1])) - 1.0),
    };
}

pub fn get_gamepad_ids() [16]i32 {
    var ids: [16]i32 = undefined;
    web_get_gamepad_ids(&ids);

    return ids;
}

pub fn window_should_close(window: api.api, value: bool) void {
    _ = window;
    _ = value;
}
