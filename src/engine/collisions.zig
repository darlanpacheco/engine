const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn next_step_2d(
    id: usize,
    size: [2]f32,
    position: [2]f32,
    velocity: [2]f32,
    hitboxes_size: []const [2]f32,
    hitboxes_position: []const [2]f32,
) bool {
    const position_next = [2]f32{
        position[0] + velocity[0],
        position[1] + velocity[1],
    };

    for (hitboxes_position, hitboxes_size, 0..) |hitbox_position, hitbox_size, index| {
        if (index == id) {
            continue;
        }

        if (hitbox_size[0] <= 0 or hitbox_size[1] <= 0) {
            continue;
        }

        const overlap =
            position_next[0] < hitbox_position[0] + hitbox_size[0] and
            position_next[0] + size[0] > hitbox_position[0] and
            position_next[1] < hitbox_position[1] + hitbox_size[1] and
            position_next[1] + size[1] > hitbox_position[1];

        if (overlap) {
            return true;
        }
    }

    return false;
}
