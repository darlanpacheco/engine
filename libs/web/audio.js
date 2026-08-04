export function createAudioManager(getMemory) {
  const audioRegistry = new Map();
  let nextAudioId = 1;
  let globalAudioCtx = null;

  function getAudioContext() {
    if (!globalAudioCtx) {
      const AudioContext = window.AudioContext || window.webkitAudioContext;
      globalAudioCtx = new AudioContext();
    }
    if (globalAudioCtx.state === "suspended") {
      globalAudioCtx.resume();
    }
    return globalAudioCtx;
  }

  ["click", "keydown", "touchstart", "mousedown"].forEach((event) => {
    window.addEventListener(
      event,
      () => {
        if (globalAudioCtx && globalAudioCtx.state === "suspended") {
          globalAudioCtx.resume();
        }
      },
      { once: true },
    );
  });

  function readWasmString(ptr) {
    const memory = getMemory();
    const bytes = new Uint8Array(memory);
    let end = ptr;
    while (bytes[end] !== 0) end++;
    return new TextDecoder().decode(bytes.subarray(ptr, end));
  }

  function web_audio_new(ptr) {
    const url = readWasmString(ptr);
    const audioCtx = getAudioContext();
    const id = nextAudioId++;

    const placeholderBuffer = audioCtx.createBuffer(1, 1, 22050);
    audioRegistry.set(id, { audioCtx, audioBuffer: placeholderBuffer });

    const request = new XMLHttpRequest();
    request.open("GET", url, true);
    request.responseType = "arraybuffer";
    request.onload = function () {
      if (request.status === 200) {
        audioCtx.decodeAudioData(
          request.response,
          (buffer) => {
            audioRegistry.set(id, { audioCtx, audioBuffer: buffer });
          },
          (err) => {
            console.error("Erro ao decodificar áudio:", url, err);
          },
        );
      }
    };
    request.send();

    return id;
  }

  function web_audio_play(id, loop = 0) {
    const audioObj = audioRegistry.get(id);
    if (!audioObj) return;

    const { audioCtx, audioBuffer } = audioObj;
    if (audioCtx.state === "suspended") {
      audioCtx.resume();
    }

    const source = audioCtx.createBufferSource();
    source.buffer = audioBuffer;
    source.loop = loop !== 0;
    source.connect(audioCtx.destination);
    source.start(0);
  }

  return {
    bindings: {
      web_audio_start: () => {
        getAudioContext();
      },
      web_audio_stop: () => {},
      web_audio_new: (ptr) => web_audio_new(ptr),
      web_audio_delete: (id) => {
        audioRegistry.delete(id);
      },
      web_audio_play: (id) => web_audio_play(id, 0),
      web_set_audio_volume: (id, volume) => {},
      web_set_global_volume: (volume) => {},
    },
  };
}
