const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn check_step_2d(
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

        if (check_collision_2d(position_next, size, hitbox_position, hitbox_size)) {
            return true;
        }
    }

    return false;
}

pub fn check_collision_2d(
    pos_a: [2]f32,
    size_a: [2]f32,
    pos_b: [2]f32,
    size_b: [2]f32,
) bool {
    return pos_a[0] < pos_b[0] + size_b[0] and
        pos_a[0] + size_a[0] > pos_b[0] and
        pos_a[1] < pos_b[1] + size_b[1] and
        pos_a[1] + size_a[1] > pos_b[1];
}
