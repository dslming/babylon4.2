```js
class Mesh {
  // 10
  render() {
    // 9
    this._effectiveMaterial.bindForSubMesh(world, this, subMesh);
  }
}

class StandardMaterial{
  // 8
  bindForSubMesh() {
    // 7
     this.bindOnlyWorldMatrix(world);
  }
}

class PushMaterial {
  // 6
  public bindOnlyWorldMatrix(world: Matrix): void {
    // 5
    this._activeEffect.setMatrix("world", world);
  }
}

class Effect {
  // 4
  setMatrix() {
    // 3
    this._engine.setMatrices(this._uniforms[uniformName], matrix.toArray() as Float32Array));
  }
}

class ThinEngine {
  // 1
  setMatrices() {
    // 0
    this._gl.uniformMatrix4fv(uniform, false, matrices);
  }
}
```
