const std = @import("std");
const api = @import("platform");
const engine = @import("engine");
const glfw = api.global.glfw;

// needs some delete and check functions

pub fn shader_new(shader_type: u32, shader_source: []const u8) u32 {
    const shader = glfw.glCreateShader(shader_type);

    const source_ptr = engine.global.c_string_ptr(shader_source);
    const source_len: i32 = @intCast(shader_source.len);

    glfw.glShaderSource(shader, 1, @ptrCast(&source_ptr), &source_len);
    glfw.glCompileShader(shader);

    return shader;
}
pub fn shader_program_new(shader_vertex: u32, shader_fragment: u32) u32 {
    const shader_program = glfw.glCreateProgram();

    glfw.glAttachShader(shader_program, shader_vertex);
    glfw.glAttachShader(shader_program, shader_fragment);
    glfw.glLinkProgram(shader_program);

    return shader_program;
}
pub fn shader_use(shader_program: u32) void {
    glfw.glUseProgram(shader_program);
}

//
//
//
//

pub fn uniform1i(name: [:0]const u8, value: i32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform1i(uniform, value);
}
pub fn uniform2i(name: [:0]const u8, value: [2]i32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform2i(uniform, value[0], value[1]);
}
pub fn uniform3i(name: [:0]const u8, value: [3]i32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform3i(uniform, value[0], value[1], value[2]);
}
pub fn uniform4i(name: [:0]const u8, value: [4]i32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform4i(uniform, value[0], value[1], value[2], value[3]);
}

//
//
//
//

pub fn uniform1f(name: [:0]const u8, value: f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform1f(uniform, value);
}
pub fn uniform2f(name: [:0]const u8, value: [2]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform2f(uniform, value[0], value[1]);
}
pub fn uniform3f(name: [:0]const u8, value: [3]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform3f(uniform, value[0], value[1], value[2]);
}
pub fn uniform4f(name: [:0]const u8, value: [4]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform4f(uniform, value[0], value[1], value[2], value[3]);
}

//
//
//
//

pub fn uniform1fv(name: [:0]const u8, value: []const f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform1fv(uniform, @intCast(value.len), value.ptr);
}
pub fn uniform2fv(name: [:0]const u8, value: []const [2]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform2fv(uniform, @intCast(value.len), @ptrCast(value.ptr));
}
pub fn uniform3fv(name: [:0]const u8, value: []const [3]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform3fv(uniform, @intCast(value.len), @ptrCast(value.ptr));
}
pub fn uniform4fv(name: [:0]const u8, value: []const [4]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniform4fv(uniform, @intCast(value.len), @ptrCast(value.ptr));
}

//
//
//
//

pub fn uniform2m(name: [:0]const u8, value: [4]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniformMatrix2fv(uniform, 1, glfw.GL_FALSE, &value[0]);
}
pub fn uniform3m(name: [:0]const u8, value: [9]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniformMatrix3fv(uniform, 1, glfw.GL_FALSE, &value[0]);
}
pub fn uniform4m(name: [:0]const u8, value: [16]f32, shader_program: u32) void {
    const uniform = glfw.glGetUniformLocation(shader_program, name.ptr);
    glfw.glUniformMatrix4fv(uniform, 1, glfw.GL_FALSE, &value[0]);
}
