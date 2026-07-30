export function createGlobalManager(canvas, getMemory) {
  let mouseX = 0;
  let mouseY = 0;
  let deltaTime = 0;

  function setDeltaTime(value) {
    deltaTime = value;
  }

  canvas.addEventListener("mousemove", (event) => {
    const rect = canvas.getBoundingClientRect();
    mouseX = event.clientX - rect.left;
    mouseY = event.clientY - rect.top;
  });

  // window.addEventListener("gamepadconnected", (e) => {
  //   console.log("gamepad connected: ", e.gamepad.id);
  // });
  // window.addEventListener("gamepaddisconnected", (e) => {
  //   console.log("gamepad disconnected: ", e.gamepad.id);
  // });

  return {
    setDeltaTime,

    bindings: {
      web_get_delta_time() {
        return deltaTime;
      },

      web_get_monitor_size(widthPtr, heightPtr) {
        const memory = getMemory();
        const viewI32 = new Int32Array(memory);
        viewI32[widthPtr / 4] = window.screen.width;
        viewI32[heightPtr / 4] = window.screen.height;
      },
      web_get_window_size(widthPtr, heightPtr) {
        const memory = getMemory();
        const viewI32 = new Int32Array(memory);
        viewI32[widthPtr / 4] = canvas.width;
        viewI32[heightPtr / 4] = canvas.height;
      },

      web_get_mouse_position(xPtr, yPtr) {
        const memory = getMemory();
        const viewF64 = new Float64Array(memory);
        viewF64[xPtr / 8] = mouseX;
        viewF64[yPtr / 8] = mouseY;
      },

      web_get_gamepad_ids(idsPtr) {
        const memory = getMemory();
        const ids = new Int32Array(memory, idsPtr, 16);
        const gamepads = navigator.getGamepads ? navigator.getGamepads() : [];

        for (let jid = 0; jid < 16; jid++) {
          const gp = gamepads[jid];
          if (gp && gp.connected) {
            ids[jid] = jid;
          } else {
            ids[jid] = -1;
          }
        }
      },
    },
  };
}
