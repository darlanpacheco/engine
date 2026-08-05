const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

const MAX_SOUNDS = 256;
var ma_sounds: [MAX_SOUNDS]?*api.global.audio.ma_sound = [_]?*api.global.audio.ma_sound{null} ** MAX_SOUNDS;
var audio_states: [MAX_SOUNDS]i32 = [_]i32{0} ** MAX_SOUNDS;

var global_mixer: ?*api.global.audio.ma_engine = null;
var initialized: bool = false;

pub fn audio_start() void {
    if (initialized) {
        if (global_mixer != null) {
            return;
        }
    }

    const miniaudio_engine = std.heap.page_allocator.create(api.global.audio.ma_engine) catch {
        @panic("audio subsystem initialization error");
    };

    if (api.global.audio.ma_engine_init(null, miniaudio_engine) != api.global.audio.MA_SUCCESS) {
        @panic("mixer initialization error");
    }

    global_mixer = miniaudio_engine;
    initialized = true;
}
pub fn audio_stop() void {
    for (&ma_sounds) |*slot| {
        if (slot.*) |s| {
            api.global.audio.ma_sound_uninit(s);
            std.heap.page_allocator.destroy(s);
            slot.* = null;
        }
    }
    @memset(&audio_states, 0);

    if (global_mixer) |mixer| {
        api.global.audio.ma_engine_uninit(mixer);
        std.heap.page_allocator.destroy(mixer);
    }
    initialized = false;
    global_mixer = null;
}

pub fn audio_new(path: []const u8) u32 {
    if (global_mixer == null) {
        @panic("global mixer error");
    }
    const mixer = global_mixer.?;

    var slot_index: ?usize = null;
    for (ma_sounds, 0..) |s, i| {
        if (s == null) {
            slot_index = i;
            break;
        }
    }

    const index = slot_index orelse @panic("max audio sounds reached");

    var path_buffer: [256]u8 = undefined;
    const c_path = api.global.c_string(&path_buffer, path);

    const sound = std.heap.page_allocator.create(api.global.audio.ma_sound) catch {
        @panic("audio load file error");
    };

    if (api.global.audio.ma_sound_init_from_file(mixer, c_path.ptr, api.global.audio.MA_SOUND_FLAG_DECODE, null, null, sound) != api.global.audio.MA_SUCCESS) {
        @panic("audio load file error");
    }

    ma_sounds[index] = sound;
    audio_states[index] = 0;

    return @intCast(index + 1);
}
pub fn audio_delete(audio_id: u32) void {
    if (audio_id == 0) return;
    const index = @as(usize, @intCast(audio_id)) - 1;
    if (index < MAX_SOUNDS) {
        if (ma_sounds[index]) |s| {
            api.global.audio.ma_sound_uninit(s);
            std.heap.page_allocator.destroy(s);
            ma_sounds[index] = null;
            audio_states[index] = 0;
        }
    }
}
pub fn audio_play(audio_id: u32, fixed: bool) void {
    if (audio_id == 0) return;
    const index = @as(usize, @intCast(audio_id)) - 1;
    if (index >= MAX_SOUNDS) return;

    const s = ma_sounds[index] orelse return;

    const current_state = 1;
    const last_state = audio_states[index];
    audio_states[index] = current_state;

    const should_play = if (fixed)
        (current_state == 1 and last_state == 0)
    else
        true;

    if (should_play) {
        if (api.global.audio.ma_sound_at_end(s) == api.global.audio.MA_TRUE) {
            _ = api.global.audio.ma_sound_seek_to_pcm_frame(s, 0);
        }
        _ = api.global.audio.ma_sound_start(s);
    }
}

pub fn set_audio_volume(audio_id: u32, volume: i32) void {
    if (audio_id == 0) return;
    const index = @as(usize, @intCast(audio_id)) - 1;
    if (index < MAX_SOUNDS) {
        if (ma_sounds[index]) |s| {
            const volume1f = @as(f32, @floatFromInt(volume));
            const clamped_volume = std.math.clamp(volume1f / 100.0, 0.0, 1.0);
            api.global.audio.ma_sound_set_volume(s, clamped_volume);
        }
    }
}
pub fn set_global_volume(volume: i32) void {
    if (global_mixer) |mixer| {
        const volume1f = @as(f32, @floatFromInt(volume));
        const clamped_volume = std.math.clamp(volume1f / 100.0, 0.0, 1.0);
        _ = api.global.audio.ma_engine_set_volume(mixer, clamped_volume);
    }
}
