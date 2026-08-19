export function createWebGLBindings(gl, getMemory, ctx) {
  return {
    webgl_create_vertex_array() {
      const id = ctx.vaoIdCounter++;
      ctx.vaoMap.set(id, gl.createVertexArray());
      return id;
    },
    webgl_create_buffer() {
      const id = ctx.bufferIdCounter++;
      ctx.bufferMap.set(id, gl.createBuffer());
      return id;
    },
    webgl_delete_vertex_array(id) {
      const v = ctx.vaoMap.get(id);
      if (v) {
        gl.deleteVertexArray(v);
        ctx.vaoMap.delete(id);
      }
    },
    webgl_delete_buffer(id) {
      const b = ctx.bufferMap.get(id);
      if (b) {
        gl.deleteBuffer(b);
        ctx.bufferMap.delete(id);
      }
    },
    webgl_bind_vertex_array(id) {
      gl.bindVertexArray(id === 0 ? null : ctx.vaoMap.get(id));
    },
    webgl_bind_array_buffer(id) {
      gl.bindBuffer(gl.ARRAY_BUFFER, id === 0 ? null : ctx.bufferMap.get(id));
    },
    webgl_bind_element_buffer(id) {
      gl.bindBuffer(
        gl.ELEMENT_ARRAY_BUFFER,
        id === 0 ? null : ctx.bufferMap.get(id),
      );
    },
    webgl_buffer_data_f32(ptr, len) {
      gl.bufferData(
        gl.ARRAY_BUFFER,
        new Float32Array(getMemory(), ptr, len),
        gl.STATIC_DRAW,
      );
    },
    webgl_buffer_data_u32(ptr, len) {
      gl.bufferData(
        gl.ELEMENT_ARRAY_BUFFER,
        new Uint32Array(getMemory(), ptr, len),
        gl.STATIC_DRAW,
      );
    },
    webgl_vertex_attrib_pointer(index, size, stride, offset) {
      gl.vertexAttribPointer(index, size, gl.FLOAT, false, stride, offset);
    },
    webgl_enable_vertex_attrib_array(index) {
      gl.enableVertexAttribArray(index);
    },
    webgl_draw_elements(mode, count, type, offset) {
      gl.drawElements(mode, count, type, offset);
    },
    webgl_active_texture(texture) {
      gl.activeTexture(texture);
    },
    webgl_enable(cap) {
      gl.enable(cap);
    },
    webgl_blend_func(sfactor, dfactor) {
      gl.blendFunc(sfactor, dfactor);
    },
  };
}
