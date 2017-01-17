require.ensure([], function(require){
    require('../libraries/lightgl/main.js');
    require('../libraries/lightgl/matrix.js');
    require('../libraries/lightgl/mesh.js');
    require('../libraries/lightgl/raytracer.js');
    require('../libraries/lightgl/shader.js');
    require('../libraries/lightgl/texture.js');
    require('../libraries/lightgl/vector.js');
});


//- require.ensure(['../libraries/lightgl/main.js'], function() {
//- })
import { GL } from '../libraries/lightgl/main';
import { GHModel } from '../models/GHModel000.js';
import { SIM } from '../libraries/sim/common';
import { TriangleMesh } from '../libraries/sim/TriMesh';



<templar>
  <style scoped>
    :scope { display: block }
    /** other tag specific styles **/
    height: 80%;
    width: 80%;
  </style>

  <script src="src/libraries/OES_texture_float_linear-polyfill.js"></script>
  <script>

//- var mynewsim = SIM(3);


//- console.log(mynewsim.centroid())

var angleX = 30;
var angleY = 30;
var gl = GL.create({
  // If we use hardware multisampling then there will be leaking around the
  // edges of triangles due to extrapolation. For more details see the article at
  // http://www.opengl.org/pipeline/article/vol003_6/. These artifacts can be
  // avoided by using centroid sampling except it isn't supported by WebGL.
  antialias: false
});
if (!gl.getExtension('OES_texture_float') || !gl.getExtension('OES_texture_float_linear')) {
  document.write('This demo requires the OES_texture_float and OES_texture_float_linear extensions to run');
  throw new Error('not supported');
}

var depthMap = new GL.Texture(1920, 1080, { format: gl.RED });
var depthShader = new GL.Shader('\
  varying vec4 pos;\
  void main() {\
    gl_Position = pos = gl_ModelViewProjectionMatrix * gl_Vertex;\
  }\
', '\
  varying vec4 pos;\
  void main() {\
    float depth = pos.z / pos.w;\
    gl_FragColor = vec4(depth * 0.5 + 0.5);\
  }\
');

var testdepthShader = new GL.Shader('\
  varying vec4 pos;\
  void main() {\
    gl_Position = pos = gl_ModelViewProjectionMatrix * gl_Vertex;\
  }\
', '\
  varying vec4 pos;\
  void main() {\
    float depth = pos.z/pos.w;\
    gl_FragColor = vec4(1.-(depth*depth*depth*depth*depth*depth*0.5));\
  }\
');

var simplestShader = new GL.Shader('\
void main() {\
  gl_Position = gl_ModelViewProjectionMatrix\
                * gl_Vertex;\
}\
', '\
void main() {\
  gl_FragColor = vec4(1.0,\
                      0.0,\
                      1.0,\
                      1.0);\
}\
');

var goodShader = new GL.Shader('\
  varying vec3 vnormal;\
  void main() {\
    vnormal = gl_NormalMatrix * gl_Normal;\
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;\
  }\
', '\
  varying vec3 vnormal;\
  void main() {\
    gl_FragColor = vec4(normalize(vnormal).xxx * 0.5 + 0.5, 0.5);\
  }\
');

var testShader = new GL.Shader('\
  varying vec3 vnormal;\
  varying vec4 pos;\
  void main() {\
    vnormal = gl_NormalMatrix * gl_Normal;\
    pos = gl_ModelViewMatrix * vec4 (gl_Position.xyz, 1.0);\
    gl_Position = gl_ModelViewProjectionMatrix * gl_Vertex;\
  }\
', '\
  varying vec3 vnormal;\
  varying vec4 pos;\
  const vec3 direction = vec3 (0.424264, 0.565685, 0.707107);\
  void main() {\
    vec3 normal = vnormal;\
    if (dot (normal, pos.xyz) > 0.0) {\
        normal *= -1.0; \
    }\
	  float brightness = dot (normal, direction);\
    gl_FragColor = vec4 (vec3 (brightness, brightness, brightness), 1.0);\
  }\
');



// Make a mesh of triangles
//var numArctriangles = 32;
var groundTilesPerSide = 0;
//var quadMesh = new QuadMesh((numArctriangles + groundTilesPerSide * groundTilesPerSide) * 2, 64);
// Arc of randomly oriented triangles
//for (var i = 0; i < numArctriangles; i++) {
//  var r = 0.3;
//  var center = GL.Vector.fromAngles(0, ((i + Math.random()) / numArctriangles) * Math.PI);
//  var a = GL.Vector.randomDirection().multiply(r);
//  var b = GL.Vector.randomDirection().cross(a).unit().multiply(r);
//  quadMesh.addDoubleQuad(
//    center.subtract(a).subtract(b),
//    center.subtract(a).add(b),
//    center.add(a).subtract(b),
//    center.add(a).add(b)
//  );
//}

var trianglessum = 0;

  //- for (var k = 0; k < GHModel.triset.length; k++) {

    //- console.log("triset : "+JSON.stringify(GHModel.triset[k]))
  //-   trianglessum += GHModel.triset[k].triangles.length;

    
  //- }

  var polygon_count = (trianglessum + groundTilesPerSide * groundTilesPerSide) * 2;
  //- console.log("Poligon Count : "+polygon_count);
  //- var TriMesh = [];
  // this should be included in TriMesh dependency
  //- console.log(JSON.stringify(GHModel))
  var mySIM = new SIM(GHModel.triset.length);


for (var j = 0; j < GHModel.triset.length; j++) {

  trianglessum += GHModel.triset[j].triangles.length;
  var data = GHModel.triset[j];

  mySIM.meshes.push(new TriangleMesh(trianglessum, 64)) ;
  //- mySIM.meshes_i.push(new TriangleMesh(trianglessum, 64)) ;

  mySIM.meshes[j].addModel(data);
  //- mySIM.meshes_i[j].addModel(data);
  mySIM.meshes[j].compile();
  //- mySIM.meshes_i[j].compile();
  //- console.log(mySIM.meshes[j].bounds);
  mySIM.centroid(mySIM.meshes[j].bounds.center);
}

// The mesh will be drawn with texture mapping
//- var mesh = TriMesh[0].mesh;
var textureMapShader = new GL.Shader('\
  varying vec2 coord;\
  void main() {\
    coord = gl_TexCoord.st;\
    gl_Position = ftransform();\
  }\
', '\
  uniform sampler2D texture;\
  varying vec2 coord;\
  void main() {\
    gl_FragColor = texture2D(texture, coord);\
  }\
');

gl.onmousemove = function(e) {
  if (e.dragging) {
    angleY += e.deltaX;
    angleX += e.deltaY;
    angleX = Math.max(-1, Math.min(90, angleX));
    //- console.log(angleY,angleX)
  }
};

var flip = false;
var tf = -1;
var scaleM = GL.Matrix.scale(0.3,0.3,0.3);
var scaleM_i = GL.Matrix.scale(tf*0.3,tf*0.3,tf*0.3);
var rotateM = GL.Matrix.rotate(tf*90,1,0,0);
var rotateM_i = GL.Matrix.rotate(90,1,0,0);
var tG = {
  x: mySIM.centroid().x,
  y: mySIM.centroid().y,
  z: mySIM.centroid().z
}
var translateM = GL.Matrix.translate(tf*tG.x,tf*tG.y,tf*tG.z);
var translateM_i = GL.Matrix.translate(1.7*tf*tG.x,tf*tG.y,tf*tG.z);
//- console.log(TriMesh.SIM.centroid().multiply(0))
//- var transformM = translateM.multiply(scaleM.multiply(rotateM));
var transformM = scaleM.multiply(rotateM.multiply(translateM))
var transformM_i = scaleM_i.multiply(rotateM_i.multiply(translateM_i))
//- var transformM = translateM;
  for (var i = 0; i < mySIM.meshes.length; i++) {
    mySIM.meshes[i].mesh.transform(transformM);
    //- mySIM.meshes_i[i].mesh.transform(transformM_i);
    //- goodShader.draw(meshes[i]);
  } 
var pov = -8;
var scaletest = GL.Matrix.scale(0.3,0.3,0.3);
this.mixin('target').observable.on('updated_target',function(e) {
  var num = 0;
  num = Number(e.value);
  //- console.log(e.id)
  if (typeof num == 'number' && e.id == 'sliderv') {
    pov = -1*num;
    //- console.log('pov updated',pov)
  } else console.log('not number');
  if (typeof num == 'number' && e.id == 'sliderh') {
    scaletest = GL.Matrix.scale(0.3,num*0.3,0.3);
    //- console.log('pov updated',pov)
  } else console.log('not number');
  //- console.log(typeof num,typeof num == 'number', -1*num, typeof pov);
});

gl.ondraw = function() {
  gl.clearColor(0.2, 0.2, 0.9, 1);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  gl.loadIdentity();
  gl.translate(0, 0, pov);
  //- gl.scale(scaleY,1, 1);
  gl.rotate(angleX, 1, 0, 0);
  gl.rotate(angleY, 0, 1, 0);
  gl.translate(0, -0.25, 0);
  // Alternate between a shadow from a random point on the sky hemisphere
  // and a random point near the light (creates a soft shadow)
  //- var dir = GL.Vector.randomDirection();
  //- flip = !flip;
  //- if (flip) dir = new GL.Vector(1, 1, 1).add(dir.multiply(0.3 * Math.sqrt(Math.random()))).unit();
  //- quadMesh.drawShadow(dir.y < 0 ? dir.negative() : dir);

  // Draw the mesh with the ambient occlusion so far
  //- quadMesh.lightmapTexture.bind();
  //- textureMapShader.draw(mesh);

  // we can add here some meshes vs meshes_i length check , i.e. they should be the same.
  for (var i = 0; i < mySIM.meshes.length; i++) {
    //- mySIM.meshes[i].mesh.transform(scaletest);
    testShader.draw(mySIM.meshes[i].mesh, gl.LINES);
    //- testShader.draw(mySIM.meshes_i[i].mesh);
    //- textureMapShader.draw(meshes[i]);
  } 
  //- goodShader.draw(meshes[1]);

  //- testShader.draw(mesh);
  //- dummyshader.draw(mesh);
//  textureMapShader.draw(testmesh);
};

gl.fullscreen();
gl.animate();
gl.enable(gl.CULL_FACE);
gl.enable(gl.DEPTH_TEST);

  </script>

</templar>