export function createWindowBindings(gl, getMemory) {
  return {
    webgl_clear_color(r, g, b, a) {
      gl.clearColor(r, g, b, a);
    },
    webgl_clear() {
      gl.clear(gl.COLOR_BUFFER_BIT);
    },
  };
}
