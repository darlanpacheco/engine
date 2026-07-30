const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

fn vao_new() u32 {
    var vao: u32 = 0;
    glfw.glGenVertexArrays(1, &vao);
    return vao;
}
fn vbo_new() u32 {
    var vbo: u32 = 0;
    glfw.glGenBuffers(1, &vbo);
    return vbo;
}
fn ebo_new() u32 {
    var ebo: u32 = 0;
    glfw.glGenBuffers(1, &ebo);
    return ebo;
}
fn vao_delete(vao: u32) void {
    glfw.glDeleteVertexArrays(1, &vao);
}
fn vbo_delete(vbo: u32) void {
    glfw.glDeleteBuffers(1, &vbo);
}
fn ebo_delete(ebo: u32) void {
    glfw.glDeleteBuffers(1, &ebo);
}

fn vao_bind_opengl(vao: u32) void {
    glfw.glBindVertexArray(vao);
}
fn vbo_bind_target(vbo: u32) void {
    glfw.glBindBuffer(glfw.GL_ARRAY_BUFFER, vbo);
}
fn vbo_bind_opengl(vertices: []const f32) void {
    glfw.glBufferData(
        glfw.GL_ARRAY_BUFFER,
        @intCast(vertices.len * @sizeOf(f32)),
        vertices.ptr,
        glfw.GL_STATIC_DRAW,
    );
}
fn ebo_bind_target(ebo: u32) void {
    glfw.glBindBuffer(glfw.GL_ELEMENT_ARRAY_BUFFER, ebo);
}
fn ebo_bind_opengl(indices_data: []const u32) void {
    glfw.glBufferData(
        glfw.GL_ELEMENT_ARRAY_BUFFER,
        @intCast(indices_data.len * @sizeOf(u32)),
        indices_data.ptr,
        glfw.GL_STATIC_DRAW,
    );
}

fn vao_unbind_opengl() void {
    glfw.glBindVertexArray(0);
}

fn vao_setup() void {
    const stride = 8 * @sizeOf(f32);

    glfw.glVertexAttribPointer(0, 3, glfw.GL_FLOAT, glfw.GL_FALSE, stride, null);
    glfw.glEnableVertexAttribArray(0);

    const offset_normal: ?*const anyopaque = @ptrFromInt(3 * @sizeOf(f32));
    glfw.glVertexAttribPointer(1, 3, glfw.GL_FLOAT, glfw.GL_FALSE, stride, offset_normal);
    glfw.glEnableVertexAttribArray(1);

    const offset_uv: ?*const anyopaque = @ptrFromInt(6 * @sizeOf(f32));
    glfw.glVertexAttribPointer(2, 2, glfw.GL_FLOAT, glfw.GL_FALSE, stride, offset_uv);
    glfw.glEnableVertexAttribArray(2);
}

//
//
//
//

pub fn geometry_new(vertices: []const f32, indices: []const u32) struct { u32, u32, u32 } {
    const vao = vao_new();
    const vbo = vbo_new();
    const ebo = ebo_new();

    vao_bind_opengl(vao);
    vbo_bind_target(vbo);
    vbo_bind_opengl(vertices);
    ebo_bind_target(ebo);
    ebo_bind_opengl(indices);

    vao_setup();
    vao_unbind_opengl();

    return .{ vao, vbo, ebo };
}
pub fn geometry_delete(vao: u32, vbo: u32, ebo: u32) void {
    vao_delete(vao);
    vbo_delete(vbo);
    ebo_delete(ebo);
}

//
//
//
//

pub fn draw_tile(vao: u32, index_count: i32) void {
    glfw.glBindVertexArray(vao);
    glfw.glDrawElements(glfw.GL_TRIANGLES, index_count, glfw.GL_UNSIGNED_INT, null);
    glfw.glBindVertexArray(0);
}
pub fn enable_blend() void {
    glfw.glEnable(engine.types.GL_BLEND);
    glfw.glBlendFunc(
        glfw.GL_SRC_ALPHA,
        glfw.GL_ONE_MINUS_SRC_ALPHA,
    );
}
