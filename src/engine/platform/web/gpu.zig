const std = @import("std");
const api = @import("platform");
const engine = @import("engine");

extern fn webgl_create_vertex_array() u32;
extern fn webgl_create_buffer() u32;

extern fn webgl_delete_vertex_array(vao: u32) void;
extern fn webgl_delete_buffer(buffer: u32) void;

extern fn webgl_bind_vertex_array(vao: u32) void;

extern fn webgl_bind_array_buffer(buffer: u32) void;
extern fn webgl_buffer_data_f32(ptr: [*]const f32, len: usize) void;

extern fn webgl_bind_element_buffer(buffer: u32) void;
extern fn webgl_buffer_data_u32(ptr: [*]const u32, len: usize) void;

extern fn webgl_vertex_attrib_pointer(index: u32, size: u32, stride: u32, offset: u32) void;
extern fn webgl_enable_vertex_attrib_array(index: u32) void;

extern fn webgl_draw_elements(mode: u32, count: i32, type: u32, offset: u32) void;
extern fn webgl_enable(cap: u32) void;
extern fn webgl_blend_func(sfactor: u32, dfactor: u32) void;

//
//
//
//

fn vao_new() u32 {
    return webgl_create_vertex_array();
}

fn vbo_new() u32 {
    return webgl_create_buffer();
}

fn ebo_new() u32 {
    return webgl_create_buffer();
}

fn vao_delete(vao: u32) void {
    webgl_delete_vertex_array(vao);
}

fn vbo_delete(vbo: u32) void {
    webgl_delete_buffer(vbo);
}

fn ebo_delete(ebo: u32) void {
    webgl_delete_buffer(ebo);
}

fn vao_bind_webgl(vao: u32) void {
    webgl_bind_vertex_array(vao);
}

fn vbo_bind_target(vbo: u32) void {
    webgl_bind_array_buffer(vbo);
}

fn vbo_bind_webgl(vertices: []const f32) void {
    webgl_buffer_data_f32(vertices.ptr, vertices.len);
}

fn ebo_bind_target(ebo: u32) void {
    webgl_bind_element_buffer(ebo);
}

fn ebo_bind_webgl(indices: []const u32) void {
    webgl_buffer_data_u32(indices.ptr, indices.len);
}

fn vao_unbind_webgl() void {
    webgl_bind_vertex_array(0);
}

fn vao_setup() void {
    const stride = 8 * @sizeOf(f32);

    webgl_vertex_attrib_pointer(0, 3, stride, 0);
    webgl_enable_vertex_attrib_array(0);

    webgl_vertex_attrib_pointer(1, 3, stride, 3 * @sizeOf(f32));
    webgl_enable_vertex_attrib_array(1);

    webgl_vertex_attrib_pointer(2, 2, stride, 6 * @sizeOf(f32));
    webgl_enable_vertex_attrib_array(2);
}

//
//
//
//

pub fn geometry_new(vertices: []const f32, indices: []const u32) struct { u32, u32, u32 } {
    const vao = vao_new();
    const vbo = vbo_new();
    const ebo = ebo_new();

    vao_bind_webgl(vao);

    vbo_bind_target(vbo);
    vbo_bind_webgl(vertices);

    ebo_bind_target(ebo);
    ebo_bind_webgl(indices);

    vao_setup();

    vao_unbind_webgl();

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
    webgl_bind_vertex_array(vao);
    webgl_draw_elements(engine.types.GL_TRIANGLES, index_count, engine.types.GL_UNSIGNED_INT, 0);
    webgl_bind_vertex_array(0);
}
pub fn enable_blend() void {
    webgl_enable(engine.types.GL_BLEND);
    webgl_blend_func(engine.types.GL_SRC_ALPHA, engine.types.GL_ONE_MINUS_SRC_ALPHA);
}
