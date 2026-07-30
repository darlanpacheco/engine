export function createInputManager(getMemory) {
  const keysPressed = {};
  const mouseButtons = {};
  const lastStates = {};

  function initListeners(canvas) {
    window.addEventListener("keydown", (e) => {
      keysPressed[e.code] = true;
    });
    window.addEventListener("keyup", (e) => {
      keysPressed[e.code] = false;
    });
    window.addEventListener("mousedown", (e) => {
      mouseButtons[e.button] = true;
    });
    window.addEventListener("mouseup", (e) => {
      mouseButtons[e.button] = false;
    });
  }

  return {
    initListeners,
    bindings: {
      web_get_key(ptr, len, fixed) {
        const bytes = new Uint8Array(getMemory(), ptr, len);
        const keyNameStr = new TextDecoder().decode(bytes);

        const keyboardMap = {
          up: "ArrowUp",
          down: "ArrowDown",
          left: "ArrowLeft",
          right: "ArrowRight",
          escape: "Escape",
          space: "Space",
          enter: "Enter",
          left_shift: "ShiftLeft",
          right_shift: "ShiftRight",
          left_control: "ControlLeft",
          right_control: "ControlRight",
        };

        let currentState = 0;

        if (keyboardMap[keyNameStr] && keysPressed[keyboardMap[keyNameStr]]) {
          currentState = 1;
        } else if (keyNameStr.length === 1) {
          const code = "Key" + keyNameStr.toUpperCase();
          if (keysPressed[code]) {
            currentState = 1;
          }
        } else if (keyNameStr === "mouse_left" && mouseButtons[0]) {
          currentState = 1;
        } else if (keyNameStr === "mouse_right" && mouseButtons[2]) {
          currentState = 1;
        }

        if (!fixed) {
          return currentState;
        }

        const lastState = lastStates[keyNameStr] || 0;
        lastStates[keyNameStr] = currentState;

        if (currentState === 1 && lastState === 0) {
          return 1;
        }

        return 0;
      },
    },
  };
}
