import * as BABYLON from "../src/index";
// https://playground.babylonjs.com/#IJS0KT#10

var createScene = function (engine:any,canvas:any) {
    // This creates a basic Babylon Scene object (non-mesh)
    var scene = new BABYLON.Scene(engine);
    var hdrTexture = new BABYLON.HDRCubeTexture("https://smashelbow.github.io/test/chun.hdr", scene, 128, false, true, false, true);

    // This creates and positions a free camera (non-mesh)
    var camera = new BABYLON.ArcRotateCamera("camera", Math.PI / 2, Math.PI / 3, 10, BABYLON.Vector3.Zero(), scene);
    scene.environmentTexture = hdrTexture;
    scene.environmentIntensity = 1;
    // This targets the camera to scene origin
    camera.setTarget(new BABYLON.Vector3(0, 1, 0));

    // This attaches the camera to the canvas
    camera.attachControl(canvas, true);
    camera.wheelPrecision = 100;
    camera.minZ = 1;
    camera.lowerRadiusLimit = 1;
    camera.inertia = 0.9;
    camera.panningInertia = 0.9;
    camera.panningSensibility = 300;
    camera.angularSensibilityX = 800;
    camera.angularSensibilityY = 800;

    var rect = engine.getRenderingCanvasClientRect();

    var hw = rect.width;

    var hh = rect.height;

    console.log(rect.width);

    var ortCamFOV = 1000;
    scene.registerBeforeRender(function () {
        rect = engine.getRenderingCanvasClientRect();

        hw = rect.width / ortCamFOV;

        hh = rect.height / ortCamFOV;
        camera.orthoLeft = -hw * camera.radius;

        camera.orthoRight = hw * camera.radius;

        camera.orthoBottom = -hh * camera.radius;

        camera.orthoTop = hh * camera.radius;

        // camera.beta = 0.01 - 0.01
        camera.wheelPrecision = 200 / camera.radius;
        camera.panningSensibility = 3000 / camera.radius;
    });
    var sun = new BABYLON.DirectionalLight("sun", new BABYLON.Vector3(-0.6, -1, -0.8), scene);
    sun.diffuse = new BABYLON.Color3(1, 0.99, 0.87);

    BABYLON.SceneLoader.Append("https://smashelbow.github.io/test/", "koduck.glb", scene, function (scene) {
        (scene.getMeshByName("Sphere.001") as any).computeBonesUsingShaders = false;
        // scene.getMeshByName("__root__").scalingDeterminant = 100
        // scene.getMeshByName("__root__").position.y = 0.5
        BABYLON.NodeMaterial.ParseFromSnippetAsync("#N1W93B#32", scene).then((node:any) => {
            (scene.getMeshByName("Sphere.001") as any).material = node;
            node.getInputBlockByPredicate((b:any) => b.name === "shadowCutOff").value = 0.8;
            // node.getInputBlockByPredicate((b) => b.name === "shadowItensity").value = 0.71
            // node.getInputBlockByPredicate((b) => b.name === "rimIntensity").value = 0.08
        });
        (scene.getMeshByName("outline") as any).computeBonesUsingShaders = false;
        BABYLON.NodeMaterial.ParseFromSnippetAsync("#N1W93B#30", scene).then((onode:any) => {
           ( scene.getMeshByName("outline") as any).material = onode;
            onode.getInputBlockByPredicate((b:any) => b.name === "shadowCutOff").value = 0.8;
            // node.getInputBlockByPredicate((b) => b.name === "shadowItensity").value = 0.71
            // node.getInputBlockByPredicate((b) => b.name === "rimIntensity").value = 0.08
        });
    });

    // Our built-in 'ground' shape.
    // var ground = BABYLON.MeshBuilder.CreateGround("ground", {width: 6, height: 6}, scene);

    return scene;
};

export {createScene};
