export function createContext() {
  return {
    vaoMap: new Map(),
    bufferMap: new Map(),
    shaderMap: new Map(),
    programMap: new Map(),
    uniformLocationMap: new Map(),
    textureMap: new Map(),

    vaoIdCounter: 1,
    bufferIdCounter: 1,
    shaderIdCounter: 1,
    programIdCounter: 1,
    uniformLocationIdCounter: 1,
    textureIdCounter: 1,

    storeUniformLocation(loc) {
      const id = this.uniformLocationIdCounter++;
      this.uniformLocationMap.set(id, loc);
      return id;
    },

    getUniformLocation(id) {
      return this.uniformLocationMap.get(id);
    },
  };
}
