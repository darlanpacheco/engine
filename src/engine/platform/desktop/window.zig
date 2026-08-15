const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

pub fn start_glfw() void {
    if (glfw.glfwInit() == 0) {
        @panic("GLFW start error");
    }
}

pub fn start(title: []const u8, window_size: [2]i32) api.api {
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MAJOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_CONTEXT_VERSION_MINOR, 3);
    glfw.glfwWindowHint(glfw.GLFW_OPENGL_PROFILE, glfw.GLFW_OPENGL_CORE_PROFILE);
    // glfw.glfwWindowHint(glfw.GLFW_RESIZABLE, glfw.GLFW_TRUE);

    var title_buffer: [256]u8 = undefined;
    const c_title = api.global.c_string(&title_buffer, title);

    const window = glfw.glfwCreateWindow(@intCast(window_size[0]), @intCast(window_size[1]), c_title.ptr, null, null);

    if (window == null) {
        glfw.glfwTerminate();
        @panic("GLFW error");
    }

    glfw.glfwMakeContextCurrent(window);

    if (glfw.gladLoadGLLoader(@ptrCast(&glfw.glfwGetProcAddress)) == 0) {
        @panic("GLAD error");
    }

    glfw.glEnable(engine.types.GL_DEPTH_TEST);
    glfw.glDepthFunc(engine.types.GL_LEQUAL);

    glfw.glEnable(engine.types.GL_BLEND);
    glfw.glBlendFunc(engine.types.GL_ONE, engine.types.GL_ONE_MINUS_SRC_ALPHA);

    glfw.glEnable(engine.types.GL_FRAMEBUFFER_SRGB);

    return window.?;
}
pub fn stop(window: api.api) void {
    glfw.glfwDestroyWindow(window);
    glfw.glfwTerminate();
}

pub fn draw_start(color: [4]f32) void {
    glfw.glClearColor(color[0], color[1], color[2], color[3]);
    glfw.glClear(engine.types.GL_COLOR_BUFFER_BIT | engine.types.GL_DEPTH_BUFFER_BIT);
}
pub fn draw_viewport(size: [2]i32) void {
    glfw.glViewport(0, 0, size[0], size[1]);
}
pub fn draw_stop(window: api.api) void {
    glfw.glfwSwapBuffers(window);
}
