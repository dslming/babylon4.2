import * as BABYLON from './lib/index'
import createScene from './case/sprite.js'

window.BABYLON = BABYLON;

var canvas
var engine
window.canvas = canvas;
window.engine = engine;


window.onload = () => {
  canvas = document.getElementById('renderCanvas');
  engine = new BABYLON.Engine(canvas, true);
  var scene = createScene();
  window.scene = scene;
  engine.runRenderLoop(function() {
    scene.render();
  });
}
