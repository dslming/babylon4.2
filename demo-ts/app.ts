import * as BABYLON from "../src/index";
import { createScene } from "./case_cartoon";
var canvas: any;
var engine: any;

window.onload = () => {
    canvas = document.getElementById("renderCanvas");
    engine = new BABYLON.Engine(canvas, true);
    var scene = createScene(engine, canvas);
    engine.runRenderLoop(function () {
        scene.render();
    });
};
