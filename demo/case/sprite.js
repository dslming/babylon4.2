const createScene = function() {
  const scene = new BABYLON.Scene(engine);

  const camera = new BABYLON.ArcRotateCamera("Camera", -Math.PI / 2, Math.PI / 2, 8, new BABYLON.Vector3(0, 0, 0));
  camera.attachControl(canvas, true);
  const light = new BABYLON.PointLight("Point", new BABYLON.Vector3(5, 10, 5));

  // Create a sprite manager
  // Parameters : name, imgUrl, capacity, cellSize, scene
  const spriteManagerTrees = new BABYLON.SpriteManager("treesManager", "textures/palm.png", 2000, { width: 512, height: 1024 });
  const tree = new BABYLON.Sprite("tree", spriteManagerTrees);
  tree.width = 1;
  tree.height = 1;

  return scene;
}
export default createScene
