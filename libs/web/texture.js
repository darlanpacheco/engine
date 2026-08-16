export function createTextureManager(getWasmExports, getMemory) {
  const images = new Map();
  const pathMap = new Map();
  let imageIdCounter = 1;

  async function loadImage(path, id) {
    try {
      const response = await fetch(path);

      if (!response.ok) {
        throw new Error(`HTTP error: ${response.status}`);
      }

      const blob = await response.blob();
      const bitmap = await createImageBitmap(blob);

      const canvas = document.createElement("canvas");
      canvas.width = bitmap.width;
      canvas.height = bitmap.height;

      const ctx = canvas.getContext("2d");
      ctx.drawImage(bitmap, 0, 0);

      const imageData = ctx.getImageData(0, 0, bitmap.width, bitmap.height);

      images.set(id, {
        ready: true,
        width: bitmap.width,
        height: bitmap.height,
        pixels: imageData.data,
      });
      console.log(`texture new: [${id}], [${bitmap.width}, ${bitmap.height}]`);
    } catch (_) {
      console.error(`texture error`);
    }
  }

  return {
    bindings: {
      engine_image_request(cPathPtr) {
        const memory = getMemory();
        const memoryBytes = new Uint8Array(memory);

        let end = cPathPtr;
        while (memoryBytes[end] !== 0) end++;

        const path = new TextDecoder().decode(
          memoryBytes.subarray(cPathPtr, end),
        );

        if (pathMap.has(path)) {
          return pathMap.get(path);
        }

        const id = imageIdCounter++;
        pathMap.set(path, id);

        images.set(id, {
          ready: false,
          width: 0,
          height: 0,
          pixels: null,
        });

        loadImage(path, id);

        return id;
      },

      engine_image_ready(id) {
        const image = images.get(id);
        return image && image.ready ? 1 : 0;
      },

      engine_image_get(id, widthPtr, heightPtr) {
        const image = images.get(id);

        if (!image || !image.ready) {
          return 0;
        }

        const memory = getMemory();
        const viewI32 = new Int32Array(memory);

        viewI32[widthPtr / 4] = image.width;
        viewI32[heightPtr / 4] = image.height;

        const byteLength = image.pixels.length;

        const ptr = getWasmExports().alloc_pixels(byteLength);

        const wasmMemoryBytes = new Uint8Array(getMemory());

        wasmMemoryBytes.set(image.pixels, ptr);

        console.log(
          `[AssetManager] Pixels da imagem ID ${id} copiados para a memória WASM no ponteiro: ${ptr}`,
        );

        return ptr;
      },

      engine_image_free(ptr) {},
    },
  };
}
