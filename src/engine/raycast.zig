const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn raycast_2d_point(size_a: [2]f32, position_a: [2]f32, position_b: [2]f32) bool {
    return (position_b[0] >= position_a[0] and
        position_b[0] <= (position_a[0] + size_a[0])) and
        (position_b[1] >= position_a[1] and
            position_b[1] <= (position_a[1] + size_a[1]));
}
pub fn raycast_2d(
    size_a: [2]f32,
    position_a: [2]f32,
    size_b: [2]f32,
    position_b: [2]f32,
) bool {
    return (position_a[0] < position_b[0] + size_b[0] and
        position_a[0] + size_a[0] > position_b[0]) and
        (position_a[1] < position_b[1] + size_b[1] and
            position_a[1] + size_a[1] > position_b[1]);
}
