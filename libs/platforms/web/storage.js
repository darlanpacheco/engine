export function createStorageManager(getWasmExports, getMemory) {
  function readString(ptr) {
    const memory = getMemory();
    const memoryBytes = new Uint8Array(memory);
    let end = ptr;
    while (memoryBytes[end] !== 0) end++;
    return new TextDecoder().decode(memoryBytes.subarray(ptr, end));
  }

  function writeString(str) {
    const encoder = new TextEncoder();
    const bytes = encoder.encode(str);
    const ptr = getWasmExports().alloc_string(bytes.length + 1);
    const memoryBytes = new Uint8Array(getMemory());
    memoryBytes.set(bytes, ptr);
    memoryBytes[ptr + bytes.length] = 0;
    return ptr;
  }

  return {
    bindings: {
      web_new(cPathPtr) {
        const path = readString(cPathPtr);
        localStorage.setItem(path, "");
      },

      web_delete(cPathPtr) {
        const path = readString(cPathPtr);
        localStorage.removeItem(path);
      },

      web_exists_file(cPathPtr) {
        const path = readString(cPathPtr);
        return localStorage.getItem(path) !== null ? 1 : 0;
      },

      web_write_file(cPathPtr, cDataPtr) {
        const path = readString(cPathPtr);
        const data = readString(cDataPtr);
        localStorage.setItem(path, data);
      },

      web_read_file(cPathPtr) {
        const path = readString(cPathPtr);
        const data = localStorage.getItem(path);
        if (data === null) return 0;
        return writeString(data);
      },
    },
  };
}
