const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

pub fn audio_start() void {
    if (engine.library.initialized) {
        if (engine.library.global_mixer != null) {
            return;
        }
    }

    const miniaudio_engine = std.heap.page_allocator.create(engine.audio.ma_engine) catch {
        @panic("audio subsystem initialization error");
    };

    if (engine.audio.ma_engine_init(null, miniaudio_engine) != engine.audio.MA_SUCCESS) {
        @panic("mixer initialization error");
    }

    engine.library.global_mixer = miniaudio_engine;
    engine.library.initialized = true;
}
pub fn audio_stop() void {
    if (engine.library.global_mixer) |mixer| {
        engine.audio.ma_engine_uninit(mixer);
        std.heap.page_allocator.destroy(mixer);
    }
    engine.library.initialized = false;
    engine.library.global_mixer = null;
}

pub fn audio_new(path: []const u8) ?*engine.audio.ma_sound {
    if (engine.library.global_mixer == null) {
        @panic("global mixer error");
    }
    const mixer = engine.library.global_mixer.?;

    var path_buffer: [256]u8 = undefined;
    const c_path = engine.global.c_string(&path_buffer, path);

    const sound = std.heap.page_allocator.create(engine.audio.ma_sound) catch {
        @panic("audio load file error");
    };

    if (engine.audio.ma_sound_init_from_file(mixer, c_path.ptr, engine.audio.MA_SOUND_FLAG_DECODE, null, null, sound) != engine.audio.MA_SUCCESS) {
        @panic("audio load file error");
    }

    return sound;
}
pub fn audio_delete(sound: ?*engine.audio.ma_sound) void {
    if (sound) |s| {
        engine.audio.ma_sound_uninit(s);
        std.heap.page_allocator.destroy(s);
    }
}

pub fn audio_play(sound: ?*engine.audio.ma_sound) void {
    if (engine.library.global_mixer != null and sound != null) {
        const s = sound.?;
        if (engine.audio.ma_sound_at_end(s) == engine.audio.MA_TRUE) {
            _ = engine.audio.ma_sound_seek_to_pcm_frame(s, 0);
        }
        _ = engine.audio.ma_sound_start(s);
    }
}

pub fn set_audio_volume(sound: ?*engine.audio.ma_sound, volume: i32) void {
    if (sound) |s| {
        const volume1f = @as(f32, @floatFromInt(volume));
        const clamped_volume = std.math.clamp(volume1f / 100.0, 0.0, 1.0);

        engine.audio.ma_sound_set_volume(s, clamped_volume);
    }
}
pub fn set_global_volume(volume: i32) void {
    if (engine.library.global_mixer) |mixer| {
        const volume1f = @as(f32, @floatFromInt(volume));
        const clamped_volume = std.math.clamp(volume1f / 100.0, 0.0, 1.0);

        _ = engine.audio.ma_engine_set_volume(mixer, clamped_volume);
    }
}
