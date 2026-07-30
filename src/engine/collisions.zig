const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn next_step_2d(
    id: usize,
    size: [2]i32,
    position: [2]i32,
    velocity: [2]f32,
    hitboxes_size: []const [2]i32,
    hitboxes_position: []const [2]i32,
) bool {
    const position_next = [2]i32{
        position[0] + @as(i32, @intFromFloat(@round(velocity[0]))),
        position[1] + @as(i32, @intFromFloat(@round(velocity[1]))),
    };

    for (hitboxes_position, hitboxes_size, 0..) |h_pos, h_size, index| {
        if (index == id) {
            continue;
        }

        if (h_size[0] == 0 or h_size[1] == 0) {
            continue;
        }

        const collision = [2]bool{
            position_next[0] < h_pos[0] + h_size[0] and position_next[0] + size[0] > h_pos[0],
            position_next[1] < h_pos[1] + h_size[1] and position_next[1] + size[1] > h_pos[1],
        };

        if (collision[0] and collision[1]) {
            return true;
        }
    }

    return false;
}
