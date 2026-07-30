const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

pub const Sound = struct {
    id: u32,
};

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

// pub fn audio_start() void {
//     web_audio_start();
// }
// pub fn audio_stop() void {
//     web_audio_stop();
// }
//
// pub fn audio_new(path: [:0]const u8) ?*Sound {
//     const id = web_audio_new(path.ptr);
//     if (id == 0) return null;
//
//     const sound = std.heap.page_allocator.create(Sound) catch return null;
//     sound.* = Sound{ .id = id };
//     return sound;
// }
//
// pub fn audio_delete(sound: ?*Sound) void {
//     if (sound) |s| {
//         web_audio_delete(s.id);
//         std.heap.page_allocator.destroy(s);
//     }
// }
//
// pub fn audio_play(sound: ?*Sound) void {
//     if (sound) |s| {
//         web_audio_play(s.id);
//     }
// }
//
// pub fn set_audio_volume(sound: ?*Sound, volume: i32) void {
//     if (sound) |s| {
//         web_set_audio_volume(s.id, volume);
//     }
// }
//
// pub fn set_global_volume(volume: i32) void {
//     web_set_global_volume(volume);
// }
