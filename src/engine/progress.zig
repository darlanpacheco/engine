const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn progress2i_new(
    origin: [2]i32,
    destination: [2]i32,
    idk: bool,
) struct { [2]i32, [2]i32, [2]i32, f32, bool } {
    return .{ origin, destination, origin, 0, idk };
}
pub fn progress2i_update(data: struct { [2]i32, [2]i32, [2]i32, f32, bool }, delta_time: f32) struct { [2]i32, [2]i32, [2]i32, f32, bool } {
    const origin = data[0];
    const destination = data[1];
    var progress = data[3];
    const idk = data[4];

    if (idk) {
        progress += delta_time;
    } else {
        progress -= delta_time;
    }

    if (progress > 1) {
        progress = 1;
    } else if (progress < 0) {
        progress = 0;
    }

    const output: [2]i32 = .{
        @intFromFloat(
            @as(f32, @floatFromInt(origin[0])) +
                @as(f32, @floatFromInt(destination[0] - origin[0])) *
                    progress,
        ),
        @intFromFloat(
            @as(f32, @floatFromInt(origin[1])) +
                @as(f32, @floatFromInt(destination[1] - origin[1])) *
                    progress,
        ),
    };

    return .{ origin, destination, output, progress, idk };
}
