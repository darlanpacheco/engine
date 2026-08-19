export function createShaderBindings(gl, getMemory, ctx) {
  return {
    webgl_create_shader(type) {
      const id = ctx.shaderIdCounter++;
      ctx.shaderMap.set(id, gl.createShader(type));
      return id;
    },
    webgl_shader_source(shaderId, count, stringPtr, lengthPtr) {
      const shader = ctx.shaderMap.get(shaderId);
      if (!shader) return;
      const memory = getMemory();
      const pointers = new Uint32Array(memory, stringPtr, count);
      const lengths = new Int32Array(memory, lengthPtr, count);
      let source = "";
      for (let i = 0; i < count; i++) {
        source += new TextDecoder().decode(
          new Uint8Array(memory, pointers[i], lengths[i]),
        );
      }
      console.log(
        `--- Shader Source for ID ${shaderId} ---\n${source}\n-----------------------------------`,
      );
      gl.shaderSource(shader, source);
    },
    webgl_compile_shader(shaderId) {
      const s = ctx.shaderMap.get(shaderId);
      if (s) {
        gl.compileShader(s);
        if (!gl.getShaderParameter(s, gl.COMPILE_STATUS))
          console.error(gl.getShaderInfoLog(s));
      }
    },
    webgl_create_program() {
      const id = ctx.programIdCounter++;
      ctx.programMap.set(id, gl.createProgram());
      return id;
    },
    webgl_attach_shader(pid, sid) {
      const p = ctx.programMap.get(pid),
        s = ctx.shaderMap.get(sid);
      if (p && s) gl.attachShader(p, s);
    },
    webgl_link_program(pid) {
      const p = ctx.programMap.get(pid);
      if (p) {
        gl.linkProgram(p);
        if (!gl.getProgramParameter(p, gl.LINK_STATUS))
          console.error(gl.getProgramInfoLog(p));
      }
    },
    webgl_use_program(pid) {
      gl.useProgram(pid === 0 ? null : ctx.programMap.get(pid));
    },
    webgl_get_uniform_location(pid, namePtr) {
      const p = ctx.programMap.get(pid);
      if (!p) return -1;
      const memory = getMemory();
      const memoryBytes = new Uint8Array(memory);
      let end = namePtr;
      while (memoryBytes[end] !== 0) end++;
      const name = new TextDecoder().decode(memoryBytes.subarray(namePtr, end));
      const loc = gl.getUniformLocation(p, name);
      return !loc ? -1 : ctx.storeUniformLocation(loc);
    },
    webgl_uniform_1i(l, v0) {
      gl.uniform1i(ctx.getUniformLocation(l), v0);
    },
    webgl_uniform_2i(l, v0, v1) {
      gl.uniform2i(ctx.getUniformLocation(l), v0, v1);
    },
    webgl_uniform_3i(l, v0, v1, v2) {
      gl.uniform3i(ctx.getUniformLocation(l), v0, v1, v2);
    },
    webgl_uniform_4i(l, v0, v1, v2, v3) {
      gl.uniform4i(ctx.getUniformLocation(l), v0, v1, v2, v3);
    },
    webgl_uniform_1f(l, v0) {
      gl.uniform1f(ctx.getUniformLocation(l), v0);
    },
    webgl_uniform_2f(l, v0, v1) {
      gl.uniform2f(ctx.getUniformLocation(l), v0, v1);
    },
    webgl_uniform_3f(l, v0, v1, v2) {
      gl.uniform3f(ctx.getUniformLocation(l), v0, v1, v2);
    },
    webgl_uniform_4f(l, v0, v1, v2, v3) {
      gl.uniform4f(ctx.getUniformLocation(l), v0, v1, v2, v3);
    },
    webgl_uniform_1fv(l, c, p) {
      gl.uniform1fv(
        ctx.getUniformLocation(l),
        new Float32Array(getMemory(), p, c),
      );
    },
    webgl_uniform_2fv(l, c, p) {
      gl.uniform2fv(
        ctx.getUniformLocation(l),
        new Float32Array(getMemory(), p, c * 2),
      );
    },
    webgl_uniform_3fv(l, c, p) {
      gl.uniform3fv(
        ctx.getUniformLocation(l),
        new Float32Array(getMemory(), p, c * 3),
      );
    },
    webgl_uniform_4fv(l, c, p) {
      gl.uniform4fv(
        ctx.getUniformLocation(l),
        new Float32Array(getMemory(), p, c * 4),
      );
    },
    webgl_uniform_matrix_2fv(l, c, t, p) {
      gl.uniformMatrix2fv(
        ctx.getUniformLocation(l),
        Boolean(t),
        new Float32Array(getMemory(), p, c * 4),
      );
    },
    webgl_uniform_matrix_3fv(l, c, t, p) {
      gl.uniformMatrix3fv(
        ctx.getUniformLocation(l),
        Boolean(t),
        new Float32Array(getMemory(), p, c * 9),
      );
    },
    webgl_uniform_matrix_4fv(l, c, t, p) {
      gl.uniformMatrix4fv(
        ctx.getUniformLocation(l),
        Boolean(t),
        new Float32Array(getMemory(), p, c * 16),
      );
    },
    webgl_create_texture() {
      const id = ctx.textureIdCounter++;
      ctx.textureMap.set(id, gl.createTexture());
      return id;
    },
    webgl_delete_texture(id) {
      const t = ctx.textureMap.get(id);
      if (t) {
        gl.deleteTexture(t);
        ctx.textureMap.delete(id);
      }
    },
    webgl_bind_texture(target, id) {
      gl.bindTexture(target, id === 0 ? null : ctx.textureMap.get(id));
    },
    webgl_tex_parameter_i(target, pname, param) {
      gl.texParameteri(target, pname, param);
    },
    webgl_tex_image_2d(
      target,
      level,
      internalformat,
      width,
      height,
      border,
      format,
      type,
      ptr,
      len,
    ) {
      gl.texImage2D(
        target,
        level,
        internalformat,
        width,
        height,
        border,
        format,
        type,
        new Uint8Array(getMemory(), ptr, len),
      );
    },
  };
}
