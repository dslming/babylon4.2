### 类简单整理
#### Node
Node is the basic class for all scene objects (Mesh, Light, Camera.)

#### PerfCounter
性能统计

#### ThinEngine
- webgl 底层api的封装
- 为了防止api多次调用,都会缓存

#### Engine
```js
_renderLoop(){
    _renderFrame()
}

```
#### Scene
```js
render(updateCameras = true, ignoreAnimations = false);
```

