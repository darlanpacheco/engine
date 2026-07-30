const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

extern fn web_get_key(name_ptr: [*]const u8, name_len: usize, fixed: i32) i32;

//
//
//
//

pub fn get_key(window: api.api, key_name: []const u8, fixed: bool) i32 {
    _ = window;

    var fixed_flag: i32 = 0;

    if (fixed) {
        fixed_flag = 1;
    } else {
        fixed_flag = 0;
    }

    return web_get_key(key_name.ptr, key_name.len, fixed_flag);
}
