const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub fn normalize(vector: [3]f32) [3]f32 {
    const length = @sqrt(vector[0] * vector[0] + vector[1] * vector[1] + vector[2] * vector[2]);
    return .{ vector[0] / length, vector[1] / length, vector[2] / length };
}

pub fn matrix16f_identity() [16]f32 {
    return .{
        1, 0, 0, 0,
        0, 1, 0, 0,
        0, 0, 1, 0,
        0, 0, 0, 1,
    };
}
pub fn matrix16f_multiply(matrix_a: [16]f32, matrix_b: [16]f32) [16]f32 {
    var result: [16]f32 = undefined;

    for (0..4) |column| {
        for (0..4) |row| {
            result[column * 4 + row] =
                matrix_a[0 * 4 + row] * matrix_b[column * 4 + 0] +
                matrix_a[1 * 4 + row] * matrix_b[column * 4 + 1] +
                matrix_a[2 * 4 + row] * matrix_b[column * 4 + 2] +
                matrix_a[3 * 4 + row] * matrix_b[column * 4 + 3];
        }
    }
    return result;
}
pub fn matrix16f_translate(position: [3]f32) [16]f32 {
    return .{
        1,           0,           0,           0,
        0,           1,           0,           0,
        0,           0,           1,           0,
        position[0], position[1], position[2], 1,
    };
}
pub fn matrix16f_rotate(angle: [3]f32) [16]f32 {
    const cx = @cos(angle[0]);
    const sx = @sin(angle[0]);
    const cy = @cos(angle[1]);
    const sy = @sin(angle[1]);
    const cz = @cos(angle[2]);
    const sz = @sin(angle[2]);

    return .{
        cy * cz,                cy * -sz,               sy,       0,
        cx * sz + sx * sy * cz, cx * cz - sx * sy * sz, -sx * cy, 0,
        sx * sz - cx * sy * cz, sx * cz + cx * sy * sz, cx * cy,  0,
        0,                      0,                      0,        1,
    };
}
pub fn matrix16f_scale(size: [3]f32) [16]f32 {
    return .{
        size[0], 0,       0,       0,
        0,       size[1], 0,       0,
        0,       0,       size[2], 0,
        0,       0,       0,       1,
    };
}

pub fn matrix16f_orthographic(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) [16]f32 {
    return .{
        2 / (right - left),               0,                                0,                            0,
        0,                                2 / (top - bottom),               0,                            0,
        0,                                0,                                -2 / (far - near),            0,
        -(right + left) / (right - left), -(top + bottom) / (top - bottom), -(far + near) / (far - near), 1,
    };
}
pub fn matrix16f_perspective(fov: f32, aspect_ratio: f32, near: f32, far: f32) [16]f32 {
    const tan_half = @tan(fov / 2);
    return .{
        1 / (aspect_ratio * tan_half), 0,            0,                                0,
        0,                             1 / tan_half, 0,                                0,
        0,                             0,            -(far + near) / (far - near),     -1,
        0,                             0,            -(2 * far * near) / (far - near), 0,
    };
}

pub fn matrix16f_look_at(eye: [3]f32, target: [3]f32, up: [3]f32) [16]f32 {
    const forward = normalize(vector3f_subtract(target, eye));
    const side = normalize(product3f_cross(forward, up));
    const up_vector = product3f_cross(side, forward);

    return .{
        side[0],                   up_vector[0],                   -forward[0],                 0,
        side[1],                   up_vector[1],                   -forward[1],                 0,
        side[2],                   up_vector[2],                   -forward[2],                 0,
        -product3f_dot(side, eye), -product3f_dot(up_vector, eye), product3f_dot(forward, eye), 1,
    };
}

pub fn vector3f_subtract(a: [3]f32, b: [3]f32) [3]f32 {
    return .{ a[0] - b[0], a[1] - b[1], a[2] - b[2] };
}

pub fn product3f_dot(a: [3]f32, b: [3]f32) f32 {
    return a[0] * b[0] + a[1] * b[1] + a[2] * b[2];
}
pub fn product3f_cross(a: [3]f32, b: [3]f32) [3]f32 {
    return .{
        a[1] * b[2] - a[2] * b[1],
        a[2] * b[0] - a[0] * b[2],
        a[0] * b[1] - a[1] * b[0],
    };
}
