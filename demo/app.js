import * as BABYLON from './lib/index'
console.error(BABYLON);

var canvas
var engine

var createScene = function() {
  var scene = new BABYLON.Scene(engine);
  var camera = new BABYLON.ArcRotateCamera("camera1", 0, Math.PI / 2, 5, BABYLON.Vector3.Zero(), scene);
  window.camera = camera;
  camera.lowerRadiusLimit = 2;
  camera.upperRadiusLimit = 10;

  camera.attachControl(canvas, true);

  var sphere = BABYLON.Mesh.CreateSphere("sphere1", 16, 2, scene);

  var pbr = new BABYLON.PBRMetallicRoughnessMaterial("pbr", scene);
  sphere.material = pbr;

  pbr.baseColor = new BABYLON.Color3(1.0, 0.766, 0.336);
  pbr.metallic = 0.;
  pbr.roughness = 0.0;
  pbr.environmentTexture = BABYLON.CubeTexture.CreateFromPrefilteredData("./textures/environment.dds", scene);

  return scene;
};




window.onload = () => {
  canvas = document.getElementById('renderCanvas');
  engine = new BABYLON.Engine(canvas, true);
  var scene = createScene();
  engine.runRenderLoop(function() {
    scene.render();
  });
}
