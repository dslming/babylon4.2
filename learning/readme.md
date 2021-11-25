### babylon.js 例子分析
```js
var canvas = document.getElementById('renderCanvas');
var engine = new BABYLON.Engine(canvas, true);

var createScene = function() {
    var scene = new BABYLON.Scene(engine);

    var camera = new BABYLON.FreeCamera('camera1', new BABYLON.Vector3(0, 5,-10), scene);
    camera.setTarget(BABYLON.Vector3.Zero());
    camera.attachControl(canvas, false);
    var light = new BABYLON.HemisphericLight('light1', new BABYLON.Vector3(0,1,0), scene);
    var sphere = BABYLON.Mesh.CreateSphere('sphere1', 16, 2, scene);
    sphere.position.y = 1;
    var ground = BABYLON.Mesh.CreateGround('ground1', 6, 6, 2, scene);
    return scene;
}
```

#### Node
Mesh, Light, Camera 类的基类

#### PerfCounter
性能统计

#### ThinEngine
- webgl 底层api的封装
- 为了防止api多次调用,都会缓存

#### Engine
```js
class Engine{
    _renderLoop(){
        _renderFrame()
    }

    recordVertexArrayObject() {
        var vao = this._gl.createVertexArray();
    }
}
```
#### Scene
```js
class Scene {
    render(updateCameras = true, ignoreAnimations = false) {
        this._processSubCameras(this.activeCamera);
    }

    _processSubCameras() {
        this._renderForCamera(camera);
    }

    _renderForCamera() {
        this._renderingManager.render(null, null, true, true);
    }
}
```

#### SubMesh
```js
class SubMesh {
    render() {
        this._renderingMesh.render(this, enableAlphaMode, this._mesh._internalAbstractMeshDataInfo._actAsRegularMesh ? this._mesh : undefined);
    }
}
```
#### RenderingGroup
```js
class RenderingGroup() {
    render() {
        // 渲染不透明
        this._renderOpaque(this._opaqueSubMeshes);
    }

    _renderOpaque() {
        submesh.render(false);
    }
}
```
#### RenderingManager
```js
class RenderingManager{
    render() {
        renderingGroup.render(customRenderFunction, renderSprites, renderParticles, activeMeshes);
    }
}
```

#### Geometry
```js
class Geometry {
    constructor() {
        // vertexData
        if (vertexData) {
            this.setAllVerticesData(vertexData, updatable);
        } else {
            this._totalVertices = 0;
            this._indices = [];
        }
        this._applyToMesh();
    }

    setAllVerticesData() {
        vertexData.applyToGeometry(this, updatable);
    }

    setVerticesData() {
        if (updatable && Array.isArray(data)) {
            // to avoid converting to Float32Array at each draw call in engine.updateDynamicVertexBuffer, we make the conversion a single time here
            data = new Float32Array(data);
        }
        var buffer = new VertexBuffer(this._engine, data, kind, updatable, this._meshes.length === 0, stride);
        this.setVerticesBuffer(buffer);
    }

    setVerticesBuffer() {

    }

    _bind() {
        this._vertexArrayObjects[effect.key] = this._engine.recordVertexArrayObject(vbs, indexToBind, effect);
    }

    _applyToMesh() {
        this._vertexBuffers[kind].create();
    }
}
```

#### Mesh
```js
class Mesh {
    static CreateSphere() {
        // 空函数,由 SphereBuilder 类实现
    }

    setVerticesData() {
        var vertexData = new VertexData();
        vertexData.set(data, kind);
        var scene = this.getScene();
        new Geometry(Geometry.RandomId(), scene, vertexData, updatable, this);
    }

    render() {
        this._bind(subMesh, effect, fillMode);
    }

    _bind() {
        // VBOs
        this._geometry._bind(effect, indexToBind);
    }
}
```

#### SphereBuilder
```js
// 重写方法
Mesh.CreateSphere = ()=>{
    SphereBuilder.CreateSphere(name, options, scene);
}

class VertexData {
    applyToMesh(mesh,updatable) {
        this._applyTo(mesh, updatable);
    }
    applyToGeometry() {
        this._applyTo(geometry, updatable);
    }

    _applyTo(meshOrGeometry, updatable) {
        if (this.positions) {
            meshOrGeometry.setVerticesData(VertexBuffer.PositionKind, this.positions, updatable);
        }

        if (this.normals) {
            meshOrGeometry.setVerticesData(VertexBuffer.NormalKind, this.normals, updatable);
        }

        if (this.indices) {
            meshOrGeometry.setIndices(this.indices, null, updatable);
        } else {
            meshOrGeometry.setIndices([], null);
        }
        return this;
    }
}

// 添加方法
VertexData.CreateSphere() {
    //....
    // Result
    var vertexData = new VertexData();
    vertexData.indices = indices;
    vertexData.positions = positions;
    vertexData.normals = normals;
    vertexData.uvs = uvs;
    return vertexData;
}

class SphereBuilder{
    static CreateSphere () {
        var sphere = new Mesh(name, scene);
        var vertexData = VertexData.CreateSphere(options);
        vertexData.applyToMesh(sphere, options.updatable);
    }
}
```

#### VertexBuffer
```js
class VertexBuffer {
    constructor() {

    }
}
```
