const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

pub const MOUSE_OFFSET: i32 = 1000;

pub const GAMEPAD_BUTTON_OFFSET: i32 = 2000;

pub const GAMEPAD_LEFT_AXIS_UP: i32 = 3000;
pub const GAMEPAD_LEFT_AXIS_DOWN: i32 = 3001;
pub const GAMEPAD_LEFT_AXIS_LEFT: i32 = 3002;
pub const GAMEPAD_LEFT_AXIS_RIGHT: i32 = 3003;

pub const GAMEPAD_RIGHT_AXIS_UP: i32 = 3004;
pub const GAMEPAD_RIGHT_AXIS_DOWN: i32 = 3005;
pub const GAMEPAD_RIGHT_AXIS_LEFT: i32 = 3006;
pub const GAMEPAD_RIGHT_AXIS_RIGHT: i32 = 3007;

pub const keyboard_map = [_]struct {
    []const u8,
    i32,
}{
    .{ "a", glfw.GLFW_KEY_A },
    .{ "b", glfw.GLFW_KEY_B },
    .{ "c", glfw.GLFW_KEY_C },
    .{ "d", glfw.GLFW_KEY_D },
    .{ "e", glfw.GLFW_KEY_E },
    .{ "f", glfw.GLFW_KEY_F },
    .{ "g", glfw.GLFW_KEY_G },
    .{ "h", glfw.GLFW_KEY_H },
    .{ "i", glfw.GLFW_KEY_I },
    .{ "j", glfw.GLFW_KEY_J },
    .{ "k", glfw.GLFW_KEY_K },
    .{ "l", glfw.GLFW_KEY_L },
    .{ "m", glfw.GLFW_KEY_M },
    .{ "n", glfw.GLFW_KEY_N },
    .{ "o", glfw.GLFW_KEY_O },
    .{ "p", glfw.GLFW_KEY_P },
    .{ "q", glfw.GLFW_KEY_Q },
    .{ "r", glfw.GLFW_KEY_R },
    .{ "s", glfw.GLFW_KEY_S },
    .{ "t", glfw.GLFW_KEY_T },
    .{ "u", glfw.GLFW_KEY_U },
    .{ "v", glfw.GLFW_KEY_V },
    .{ "w", glfw.GLFW_KEY_W },
    .{ "x", glfw.GLFW_KEY_X },
    .{ "y", glfw.GLFW_KEY_Y },
    .{ "z", glfw.GLFW_KEY_Z },
    .{ "up", glfw.GLFW_KEY_UP },
    .{ "down", glfw.GLFW_KEY_DOWN },
    .{ "left", glfw.GLFW_KEY_LEFT },
    .{ "right", glfw.GLFW_KEY_RIGHT },
    .{ "escape", glfw.GLFW_KEY_ESCAPE },
    .{ "space", glfw.GLFW_KEY_SPACE },
    .{ "enter", glfw.GLFW_KEY_ENTER },
    .{ "left_shift", glfw.GLFW_KEY_LEFT_SHIFT },
    .{ "right_shift", glfw.GLFW_KEY_RIGHT_SHIFT },
    .{ "left_control", glfw.GLFW_KEY_LEFT_CONTROL },
    .{ "right_control", glfw.GLFW_KEY_RIGHT_CONTROL },

    .{ "mouse_left", MOUSE_OFFSET + glfw.GLFW_MOUSE_BUTTON_LEFT },
    .{ "mouse_right", MOUSE_OFFSET + glfw.GLFW_MOUSE_BUTTON_RIGHT },

    .{ "south", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_A },
    .{ "east", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_B },
    .{ "west", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_X },
    .{ "north", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_Y },
    .{ "left_shoulder", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_LEFT_BUMPER },
    .{ "right_shoulder", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_RIGHT_BUMPER },
    .{ "start", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_START },
    .{ "back", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_BACK },
    .{ "dpad_up", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_DPAD_UP },
    .{ "dpad_down", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_DPAD_DOWN },
    .{ "dpad_left", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_DPAD_LEFT },
    .{ "dpad_right", GAMEPAD_BUTTON_OFFSET + glfw.GLFW_GAMEPAD_BUTTON_DPAD_RIGHT },

    .{ "left_analog_up", GAMEPAD_LEFT_AXIS_UP },
    .{ "left_analog_down", GAMEPAD_LEFT_AXIS_DOWN },
    .{ "left_analog_left", GAMEPAD_LEFT_AXIS_LEFT },
    .{ "left_analog_right", GAMEPAD_LEFT_AXIS_RIGHT },

    .{ "right_analog_up", GAMEPAD_RIGHT_AXIS_UP },
    .{ "right_analog_down", GAMEPAD_RIGHT_AXIS_DOWN },
    .{ "right_analog_left", GAMEPAD_RIGHT_AXIS_LEFT },
    .{ "right_analog_right", GAMEPAD_RIGHT_AXIS_RIGHT },
};
var internal_states = [_]i32{0} ** keyboard_map.len;

fn apply_fixed(key_name: []const u8, current_state: i32) i32 {
    var key_index: ?usize = null;
    for (keyboard_map, 0..) |k, i| {
        if (std.mem.eql(u8, key_name, k[0])) {
            key_index = i;
            break;
        }
    }

    const idx = key_index orelse return 0;
    const last_state = internal_states[idx];
    internal_states[idx] = current_state;

    if (current_state == 1 and last_state == 0) {
        return 1;
    }

    return 0;
}
pub fn get_key(window: api.api, key_name: []const u8, fixed: bool) i32 {
    var raw_state: i32 = 0;

    for (keyboard_map) |k| {
        if (std.mem.eql(u8, key_name, k[0])) {
            const code = k[1];

            if (code < MOUSE_OFFSET) {
                raw_state = @intFromBool(glfw.glfwGetKey(window, code) == glfw.GLFW_PRESS);
                break;
            }

            if (code < GAMEPAD_BUTTON_OFFSET) {
                const mouse_button = code - MOUSE_OFFSET;
                raw_state = @intFromBool(glfw.glfwGetMouseButton(window, mouse_button) == glfw.GLFW_PRESS);
                break;
            }

            var state: glfw.struct_GLFWgamepadstate = undefined;
            if (glfw.glfwGetGamepadState(glfw.GLFW_JOYSTICK_1, &state) == glfw.GLFW_TRUE) {
                if (code < GAMEPAD_LEFT_AXIS_UP) {
                    const btn_id = @as(usize, @intCast(code - GAMEPAD_BUTTON_OFFSET));
                    raw_state = @intFromBool(state.buttons[btn_id] == glfw.GLFW_PRESS);
                    break;
                }

                if (code == GAMEPAD_LEFT_AXIS_UP) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_LEFT_Y] < -0.5);
                    break;
                }
                if (code == GAMEPAD_LEFT_AXIS_DOWN) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_LEFT_Y] > 0.5);
                    break;
                }
                if (code == GAMEPAD_LEFT_AXIS_LEFT) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_LEFT_X] < -0.5);
                    break;
                }
                if (code == GAMEPAD_LEFT_AXIS_RIGHT) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_LEFT_X] > 0.5);
                    break;
                }

                if (code == GAMEPAD_RIGHT_AXIS_UP) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_RIGHT_Y] < -0.5);
                    break;
                }
                if (code == GAMEPAD_RIGHT_AXIS_DOWN) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_RIGHT_Y] > 0.5);
                    break;
                }
                if (code == GAMEPAD_RIGHT_AXIS_LEFT) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_RIGHT_X] < -0.5);
                    break;
                }
                if (code == GAMEPAD_RIGHT_AXIS_RIGHT) {
                    raw_state = @intFromBool(state.axes[glfw.GLFW_GAMEPAD_AXIS_RIGHT_X] > 0.5);
                    break;
                }
            }

            raw_state = 0;
            break;
        }
    }

    if (fixed) {
        return apply_fixed(key_name, raw_state);
    }

    return raw_state;
}

pub fn any_input_pressed(
    window: api.api,
    deadzone: f32,
) i32 {
    var gamepad: glfw.struct_GLFWgamepadstate = undefined;
    if (glfw.glfwGetGamepadState(glfw.GLFW_JOYSTICK_1, &gamepad) == glfw.GLFW_TRUE) {
        for (gamepad.buttons) |btn_gamepad| {
            if (btn_gamepad == glfw.GLFW_PRESS) {
                return 1;
            }
        }

        var axis_idx: usize = 0;
        while (axis_idx < 4) : (axis_idx += 1) {
            const axis_value = gamepad.axes[axis_idx];
            if (@abs(axis_value) > deadzone) {
                return 1;
            }
        }

        if (gamepad.axes[4] > 0.0 or gamepad.axes[5] > 0.0) {
            return 1;
        }
    }

    for (keyboard_map) |k| {
        if (glfw.glfwGetKey(window, k[1]) == glfw.GLFW_PRESS) {
            return 2;
        }
    }

    var mouse: i32 = 0;
    while (mouse <= glfw.GLFW_MOUSE_BUTTON_LAST) : (mouse += 1) {
        if (glfw.glfwGetMouseButton(window, mouse) == glfw.GLFW_PRESS) {
            return 3;
        }
    }

    return 0;
}
