const builtin = @import("builtin");

const is_desktop = builtin.target.cpu.arch != .wasm32;
const is_web = builtin.target.cpu.arch == .wasm32;

pub const api = if (is_desktop)
    @import("desktop/global.zig").api
else if (is_web)
    bool
else
    bool;

pub const audio = if (is_desktop)
    @import("desktop/audio.zig")
else
    @import("web/audio.zig");

pub const global = if (is_desktop)
    @import("desktop/global.zig")
else
    @import("web/global.zig");

pub const gpu = if (is_desktop)
    @import("desktop/gpu.zig")
else
    @import("web/gpu.zig");

pub const input = if (is_desktop)
    @import("desktop/input.zig")
else
    @import("web/input.zig");

pub const shader = if (is_desktop)
    @import("desktop/shader.zig")
else
    @import("web/shader.zig");

pub const window = if (is_desktop)
    @import("desktop/window.zig")
else
    @import("web/window.zig");

pub const texture = if (is_desktop)
    @import("desktop/texture.zig")
else
    @import("web/texture.zig");
