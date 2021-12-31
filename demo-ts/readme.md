	raycast(raycaster, intersects) {

	  if (raycaster.camera === null) {

	    console.error('THREE.Sprite: "Raycaster.camera" needs to be set in order to raycast against sprites.');

		}
		return this.aaa(raycaster)
		this.center = new Vector2(0, 0);
	  _worldScale.setFromMatrixScale(this.matrixWorld);

	  _viewWorldMatrix.copy(raycaster.camera.matrixWorld);
	  this.modelViewMatrix.multiplyMatrices(raycaster.camera.matrixWorldInverse, this.matrixWorld);

	  _mvPosition.setFromMatrixPosition(this.modelViewMatrix);

	  if (raycaster.camera.isPerspectiveCamera) {

	    // _worldScale.multiplyScalar(_mvPosition.z);

	  }

	  // const rotation = this.material.rotation;
	  let sin, cos;

	  // if (rotation !== 0) {

	  //   cos = Math.cos(rotation);
	  //   sin = Math.sin(rotation);

	  // }

	  const center = this.center;

	  transformVertex(_vA.set(0, 10, 0), _mvPosition, center, _worldScale, sin, cos);
	  transformVertex(_vB.set(10, 10, 0), _mvPosition, center, _worldScale, sin, cos);
	  transformVertex(_vC.set(10, -10, 0), _mvPosition, center, _worldScale, sin, cos);
		// console.error(_vA.clone(), _vB.clone(), _vC.clone());

	  let intersect = raycaster.ray.intersectTriangle(_vA, _vB, _vC, false, _intersectPoint);

	  // check first triangle

	  if (intersect === null) {

	    // check second triangle
			transformVertex(_vB.set(0, -10, 0), _mvPosition, center, _worldScale, sin, cos);
	    intersect = raycaster.ray.intersectTriangle(_vA, _vC, _vB, false, _intersectPoint);
	    if (intersect === null) {
	      return;
	    }
	  }

	  const distance = raycaster.ray.origin.distanceTo(_intersectPoint);

	  if (distance < raycaster.near || distance > raycaster.far) return;

	  intersects.push({
	    distance: distance,
	    point: _intersectPoint.clone(),
	    face: null,
	    object: this
	  });

	}



```js
// import Stage from 'three_stage'
// import * as THREE from 'three'
// import * as dat from "dat.gui";

  import { Line2 } from './lines/Line2.js';
  import { LineMaterial } from './lines/LineMaterial.js';
  import { LineGeometry } from './lines/LineGeometry.js';

  import * as THREE from 'three';

  import Stats from 'three/examples/jsm/libs/stats.module.js';

  // import { GUI } from './jsm/libs/dat.gui.module.js';
  import { OrbitControls } from 'three/examples/jsm/controls/OrbitControls.js';
//   import { Line2 } from 'three/examples/jsm/lines/Line2.js';
//   import { LineMaterial } from 'three/examples/jsm/lines/LineMaterial.js';
// import { LineGeometry } from 'three/examples/jsm/lines/LineGeometry.js';

// window.THREE = THREE
// class Options {
//   constructor() {
//     this.color = 0.5
//   }
// };

class App {
  constructor() {
    window.lm = this
    this.settings = this.settings.bind(this)
    this.stage = new Stage("#app")
    this.stage.run()
    this.settings()

    this.addLine()
    // this.cube = this.addBox(0.5)
    // this.addSprite()
    this.stage.camera.position.set(-40, 0, 60);
    this._raycaster = new THREE.Raycaster();
    this.callback = this.callback.bind(this)
    this.stage.renderer.domElement.addEventListener('click', this.callback, false);
  }

  addSprite() {
    const sprite1 = new THREE.Sprite(new THREE.SpriteMaterial({
      color: '#69f',
      sizeAttenuation: false
    }));
    sprite1.position.set(6, -10, 5);
    sprite1.scale.set(0.2, 0.2, );
    this.stage.scene.add(sprite1)
  }

  settings() {
    var options = new Options();
    this.options = options

    var gui = new dat.GUI();
    const controller = gui.add(options, 'color', 0, 1);
    controller.onChange(value => {
      this.material && (this.material.uniforms.uColor.value = +value)
    })
  }

  addBox(size) {
    var geometry = new THREE.BoxBufferGeometry(size, size, size);
    var material = new THREE.MeshBasicMaterial()
    var cube = new THREE.Mesh(geometry, material);
    this.stage.scene.add(cube)
    this.material = material
    // cube.position.set(-10,0,0)
    return cube
  }

  callback(e) {
    const dom = this.stage.renderer.domElement;
    const mouse = {
      x: e.offsetX / dom.clientWidth * 2 - 1,
      y: -(e.offsetY / dom.clientHeight) * 2 + 1
    }

    this._raycaster.setFromCamera(new THREE.Vector2(mouse.x, mouse.y), this.stage.camera);
    const objects = this._raycaster.intersectObject(this.stage.scene, true)
    objects.forEach(item => {
      console.error(item.object.type);
    })
  }

  addLine() {
    var positions = [
      0, 0, 0,
      10, 0, 0
    ];

    const geometry = new LineGeometry();
    geometry.setPositions(positions);

    let matLine = new LineMaterial({
      color: 0xff0000,
      lineWidth: 5, // in pixels
      dashed: false,
    });

    const line = new Line2(geometry, matLine);
    line.computeLineDistances();
    line.scale.set(1, 1, 1);
    this.stage.scene.add(line)

    this.stage.onUpdate(() => {
      matLine.resolution.set(window.innerWidth, window.innerHeight);
    })
  }
}

window.onload = () => {
  let app = new App()


  // var line, renderer, scene, camera, camera2, controls;
  // var line1;
  // var matLine, matLineBasic, matLineDashed;
  // var stats;
  // var gui;

  // // viewport
  // var insetWidth;
  // var insetHeight;

  // init();
  // animate();

  // var _raycaster = new THREE.Raycaster();

  // function callback(e) {
  //   const dom = renderer.domElement;
  //   const mouse = {
  //     x: e.offsetX / dom.clientWidth * 2 - 1,
  //     y: -(e.offsetY / dom.clientHeight) * 2 + 1
  //   }

  //   _raycaster.setFromCamera(new THREE.Vector2(mouse.x, mouse.y), camera);
  //   const objects = _raycaster.intersectObject(scene, true)
  //   objects.forEach(item => {
  //     console.error(item.object.type);
  //   })
  // }

  // callback = callback.bind(this)

  // function init() {

  //   renderer = new THREE.WebGLRenderer({ antialias: true });
  //   renderer.setPixelRatio(window.devicePixelRatio);
  //   renderer.setClearColor(0x000000, 0.0);
  //   renderer.setSize(window.innerWidth, window.innerHeight);
  //   document.querySelector('#app').appendChild(renderer.domElement);

  //   scene = new THREE.Scene();

  //   camera = new THREE.PerspectiveCamera(40, window.innerWidth / window.innerHeight, 1, 1000);
  //   camera.position.set(-40, 0, 60);

  //   // camera2 = new THREE.PerspectiveCamera( 40, 1, 1, 1000 );
  //   // camera2.position.copy( camera.position );

  //   controls = new OrbitControls(camera, renderer.domElement);
  //   controls.minDistance = 10;
  //   controls.maxDistance = 500;

  //   renderer.domElement.addEventListener('click', callback, false);

  //   // Position and THREE.Color Data

  //   var positions = [
  //     0, 0, 0,
  //     10, 0, 0
  //   ];

  //   var geometry = new LineGeometry();
  //   geometry.setPositions(positions);
  //   matLine = new LineMaterial({
  //     color: 0xffffff,
  //     linewidth: 5, // in pixels
  //     dashed: false
  //   });

  //   line = new Line2(geometry, matLine);
  //   line.computeLineDistances();
  //   line.scale.set(1, 1, 1);
  //   scene.add(line);

  //   window.addEventListener('resize', onWindowResize, false);
  //   onWindowResize();

  //   stats = new Stats();
  //   document.body.appendChild(stats.dom);


  // }

  // function onWindowResize() {
  //   camera.aspect = window.innerWidth / window.innerHeight;
  //   camera.updateProjectionMatrix();
  //   renderer.setSize(window.innerWidth, window.innerHeight);
  // }

  // function animate() {
  //   requestAnimationFrame(animate);
  //   stats.update();
  //   matLine.resolution.set(window.innerWidth, window.innerHeight); // resolution of the viewport
  //   renderer.render(scene, camera);
  // }
}

```
