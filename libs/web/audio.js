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

  ["click", "keydown", "touchstart"].forEach((event) => {
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

  async function web_audio_new(url) {
    const audioCtx = getAudioContext();

    try {
      const resposta = await fetch(url);
      const arrayBuffer = await resposta.arrayBuffer();
      const audioBuffer = await audioCtx.decodeAudioData(arrayBuffer);

      const id = nextAudioId++;
      audioRegistry.set(id, { audioCtx, audioBuffer });
      // console.log("Áudio carregado e pronto! ID:", id);
      return id;
    } catch (erro) {
      // console.error("Erro ao carregar o áudio:", erro);
      return 0;
    }
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

    return source;
  }

  return {
    bindings: {
      web_audio_start: () => {},
      web_audio_stop: () => {},
      web_audio_new: async (ptr) => {
        const url = readWasmString(ptr);
        return await web_audio_new(url);
      },
      web_audio_delete: (id) => {
        audioRegistry.delete(id);
      },
      web_audio_play: (id) => web_audio_play(id, 0),
      web_set_audio_volume: (id, volume) => {},
      web_set_global_volume: (volume) => {},
    },
  };
}
