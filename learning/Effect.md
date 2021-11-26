#### Effect
包含可以在对象上执行的顶点和片段着色器的效果。


createEffect()

#### gl.createProgram()顺序

```js
class Mesh {
  // 18
  render(){
    //17
  }
}
class StandardMaterial{
  // 16
  isReadyForSubMesh(){
    // 15
    let effect = scene.getEngine().createEffect()
  }
}

class ShaderProcessor{
  // 14
  static Process(){
    // 13
  }

  // 15
  static _ProcessIncludes(){

  }
}

class Effect {
  constructor(){
    // 12
    this._useFinalCode()
  }

  // 11
  _useFinalCode(){
    // 10
    _prepareEffect()
  }

  // 9
  _prepareEffect(){
    // 8
    engine._preparePipelineContext()
  }
}

class ThinEngine{
  // 3
  createShaderProgram(){
    // 2
    this._createShaderProgram()
  }

  // 7
  _preparePipelineContext(){
    // 6
    this.createShaderProgram()
  }
}

class Engine extends ThinEngine{
  // 1
  _createShaderProgram(){
    // 0
    context.createProgram();
  }

  // 5
  createShaderProgram(){
    // 4
    super.createShaderProgram()
  }
}
```
