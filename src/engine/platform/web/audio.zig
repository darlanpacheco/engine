const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

extern fn web_audio_start() void;
extern fn web_audio_stop() void;
extern fn web_audio_new(path: [*:0]const u8) u32;
extern fn web_audio_delete(id: u32) void;
extern fn web_audio_play(id: u32) void;
extern fn web_set_audio_volume(id: u32, volume: i32) void;
extern fn web_set_global_volume(volume: i32) void;

//
//
//
//

pub fn audio_start() void {
    web_audio_start();
}
pub fn audio_stop() void {
    web_audio_stop();
}

pub fn audio_new(path: []const u8) u32 {
    var path_buffer: [256]u8 = undefined;
    if (path.len >= path_buffer.len) {
        @panic("audio path too long");
    }
    @memcpy(path_buffer[0..path.len], path);
    path_buffer[path.len] = 0;

    const id = web_audio_new(@ptrCast(&path_buffer));
    if (id == 0) {
        @panic("audio load file error");
    }

    return id;
}
pub fn audio_delete(audio_id: u32) void {
    if (audio_id == 0) return;
    web_audio_delete(audio_id);
}
pub fn audio_play(audio_id: u32) void {
    if (audio_id == 0) return;
    web_audio_play(audio_id);
}

pub fn set_audio_volume(audio_id: u32, volume: i32) void {
    if (audio_id == 0) return;
    web_set_audio_volume(audio_id, volume);
}
pub fn set_global_volume(volume: i32) void {
    web_set_global_volume(volume);
}
