const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

extern fn webgl_create_shader(shader_type: u32) u32;
extern fn webgl_shader_source(shader: u32, count: i32, string: [*]const [*]const u8, length: [*]const i32) void;
extern fn webgl_compile_shader(shader: u32) void;
extern fn webgl_create_program() u32;
extern fn webgl_attach_shader(program: u32, shader: u32) void;
extern fn webgl_link_program(program: u32) void;
extern fn webgl_use_program(program: u32) void;

extern fn webgl_get_uniform_location(program: u32, name: [*]const u8) i32;
extern fn webgl_uniform_1i(location: i32, v0: i32) void;
extern fn webgl_uniform_2i(location: i32, v0: i32, v1: i32) void;
extern fn webgl_uniform_3i(location: i32, v0: i32, v1: i32, v2: i32) void;
extern fn webgl_uniform_4i(location: i32, v0: i32, v1: i32, v2: i32, v3: i32) void;
extern fn webgl_uniform_1f(location: i32, v0: f32) void;
extern fn webgl_uniform_2f(location: i32, v0: f32, v1: f32) void;
extern fn webgl_uniform_3f(location: i32, v0: f32, v1: f32, v2: f32) void;
extern fn webgl_uniform_4f(location: i32, v0: f32, v1: f32, v2: f32, v3: f32) void;
extern fn webgl_uniform_1fv(location: i32, count: i32, value: [*]const f32) void;
extern fn webgl_uniform_2fv(location: i32, count: i32, value: [*]const f32) void;
extern fn webgl_uniform_3fv(location: i32, count: i32, value: [*]const f32) void;
extern fn webgl_uniform_4fv(location: i32, count: i32, value: [*]const f32) void;
extern fn webgl_uniform_matrix_2fv(location: i32, count: i32, transpose: bool, value: [*]const f32) void;
extern fn webgl_uniform_matrix_3fv(location: i32, count: i32, transpose: bool, value: [*]const f32) void;
extern fn webgl_uniform_matrix_4fv(location: i32, count: i32, transpose: bool, value: [*]const f32) void;

//
//
//
//

pub fn uniform_location(name: [:0]const u8, shader_program: u32) i32 {
    return webgl_get_uniform_location(
        shader_program,
        name.ptr,
    );
}

pub fn shader_new(shader_type: u32, shader_source: []const u8) u32 {
    const shader = webgl_create_shader(shader_type);
    const source_ptr = shader_source.ptr;
    const source_len: i32 = @intCast(shader_source.len);
    webgl_shader_source(shader, 1, @ptrCast(&source_ptr), @ptrCast(&source_len));
    webgl_compile_shader(shader);
    return shader;
}
pub fn shader_program_new(shader_vertex: u32, shader_fragment: u32) u32 {
    const shader_program = webgl_create_program();
    webgl_attach_shader(shader_program, shader_vertex);
    webgl_attach_shader(shader_program, shader_fragment);
    webgl_link_program(shader_program);
    return shader_program;
}
pub fn shader_use(shader_program: u32) void {
    webgl_use_program(shader_program);
}

//
//
//
//

pub fn uniform1i(name: [:0]const u8, value: i32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_1i(loc, value);
}
pub fn uniform2i(name: [:0]const u8, value: [2]i32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_2i(loc, value[0], value[1]);
}
pub fn uniform3i(name: [:0]const u8, value: [3]i32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_3i(loc, value[0], value[1], value[2]);
}
pub fn uniform4i(name: [:0]const u8, value: [4]i32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_4i(loc, value[0], value[1], value[2], value[3]);
}

//
//
//
//

pub fn uniform1f(name: [:0]const u8, value: f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_1f(loc, value);
}
pub fn uniform2f(name: [:0]const u8, value: [2]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_2f(loc, value[0], value[1]);
}
pub fn uniform3f(name: [:0]const u8, value: [3]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_3f(loc, value[0], value[1], value[2]);
}
pub fn uniform4f(name: [:0]const u8, value: [4]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_4f(loc, value[0], value[1], value[2], value[3]);
}

//
//
//
//

pub fn uniform1fv(name: [:0]const u8, value: []const f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_1fv(loc, @intCast(value.len), value.ptr);
}
pub fn uniform2fv(name: [:0]const u8, value: []const [2]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_2fv(loc, @intCast(value.len), @ptrCast(value.ptr));
}
pub fn uniform3fv(name: [:0]const u8, value: []const [3]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_3fv(loc, @intCast(value.len), @ptrCast(value.ptr));
}
pub fn uniform4fv(name: [:0]const u8, value: []const [4]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_4fv(loc, @intCast(value.len), @ptrCast(value.ptr));
}

//
//
//
//

pub fn uniform2m(name: [:0]const u8, value: [4]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_matrix_2fv(loc, 1, false, &value[0]);
}
pub fn uniform3m(name: [:0]const u8, value: [9]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_matrix_3fv(loc, 1, false, &value[0]);
}
pub fn uniform4m(name: [:0]const u8, value: [16]f32, shader_program: u32) void {
    const loc = webgl_get_uniform_location(shader_program, name.ptr);
    webgl_uniform_matrix_4fv(loc, 1, false, value[0..].ptr);
}
