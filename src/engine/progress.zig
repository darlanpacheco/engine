const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn progress_new(
    origin: [2]f32,
    destination: [2]f32,
    forward: bool,
) struct { [2]f32, [2]f32, [2]f32, f32, bool } {
    return .{ origin, destination, origin, 0, forward };
}
pub fn progress_update(data: struct { [2]f32, [2]f32, [2]f32, f32, bool }, delta_time: f32) struct { [2]f32, [2]f32, [2]f32, f32, bool } {
    const origin = data[0];
    const destination = data[1];
    var progress = data[3];
    const forward = data[4];

    if (forward) {
        progress += delta_time;
    } else {
        progress -= delta_time;
    }

    if (progress > 1) {
        progress = 1;
    } else if (progress < 0) {
        progress = 0;
    }

    const output: [2]f32 = .{
        origin[0] + (destination[0] - origin[0]) * progress,
        origin[1] + (destination[1] - origin[1]) * progress,
    };

    return .{ origin, destination, output, progress, forward };
}

pub fn timer_new(
    duration: f32,
    forward: bool,
) struct { f32, f32, bool } {
    return .{ 0, duration, forward };
}
pub fn timer_update(
    data: struct { f32, f32, bool },
    delta_time: f32,
) struct { f32, f32, bool } {
    var progress = data[0];
    const duration = data[1];
    const forward = data[2];

    if (forward) {
        progress += delta_time / duration;
    } else {
        progress -= delta_time / duration;
    }

    if (progress > 1) {
        progress = 1;
    } else if (progress < 0) {
        progress = 0;
    }

    return .{ progress, duration, forward };
}
pub fn timer_reset(data: struct { f32, f32, bool }) struct { f32, f32, bool } {
    const duration = data[1];
    const forward = data[2];

    return .{ 0, duration, forward };
}
