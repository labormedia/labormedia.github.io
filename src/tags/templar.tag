<templar>
  <style scoped>
    :scope { display: block }
    /** other tag specific styles **/
    height: 80%;
    width: 80%;
  </style>
  <script src="src/libraries/TriMesh.js"></script>
  <script src="src/libraries/gl-matrix.js"></script>
  <script src="src/libraries/lightgl.js"></script>
  <script src="src/models/param_test005.js"></script>
  <script>

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





var shadowTestShader = new GL.Shader('\
  uniform mat4 shadowMapMatrix;\
  uniform vec3 light;\
  attribute vec2 offsetCoord;\
  attribute vec4 offsetPosition;\
  varying vec4 coord;\
  varying vec3 normal;\
  \
  void main() {\
    normal = gl_Normal;\
    vec4 pos = offsetPosition;\
    \
    /*\
     * This is a hack that avoids leaking light immediately behind polygons by\
     * darkening creases in front of polygons instead. It biases the position\
     * forward toward the light to compensate for the bias away from the light\
     * applied by the fragment shader. This is only necessary because we have\
     * infinitely thin geometry and is not needed with the solid geometry\
     * present in most scenes. I made this hack up and have not seen it before.\
     */\
    pos.xyz += normalize(cross(normal, cross(normal, light))) * 0.02;\
    \
    coord = shadowMapMatrix * pos;\
    gl_Position = vec4(offsetCoord * 2.0 - 1.0, 0.0, 1.0);\
  }\
', '\
  uniform float sampleCount;\
  uniform sampler2D depthMap;\
  uniform vec3 light;\
  varying vec4 coord;\
  varying vec3 normal;\
  \
  void main() {\
    /* Run shadow test */\
    const float bias = -0.0025;\
    float depth = texture2D(depthMap, coord.xy / coord.w * 0.5 + 0.5).r;\
    float shadow = (bias + coord.z / coord.w * 0.5 + 0.5 - depth > 0.0) ? 1.0 : 0.0;\
    \
    /* Points on polygons facing away from the light are always in shadow */\
    float color = dot(normal, light) > 0.0 ? 1.0 - shadow : 0.0;\
    gl_FragColor = vec4(vec3(color), 1.0 / (1.0 + sampleCount));\
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
  console.log("Poligon Count : "+polygon_count);
  var TriMesh = [];
  var meshes = [];

for (var j = 0; j < GHModel.triset.length; j++) {
  trianglessum += GHModel.triset[j].triangles.length;
  //- console.log("number of triangles for mesh "+j+" : "+trianglessum);
  TriMesh.push(new TriangleMesh(trianglessum, 64)) ;

  //- var offset = new GL.Vector(0,0,0);
  //- var transformM = GL.Matrix.rotate(-90, 1, 0, 0);
  //- var transformM = GL.Matrix.scale(0.005,0.005,0.005);
  //- var data = GHModel.triset[j];
  //- TriMesh[j].addVertices(GHModel.triset[j].vertices);
  //- TriMesh[j].addNormals(GHModel.triset[j].normals);
  //- TriMesh[j].addTriangles(GHModel.triset[j].triangles);
  TriMesh[j].mesh = GL.Mesh.load(GHModel.triset[j]);





//- var tilesize = 7
//- var tileoffset = new GL.Vector((-tilesize+1)/2, 0, (-tilesize+1)/2)
  TriMesh[j].mesh.computeNormals();
  //- TriMesh[j].mesh.computeWireframe();
  TriMesh[j].compile();
  meshes.push(TriMesh[j].mesh)
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
    angleX = Math.max(-90, Math.min(90, angleX));
  }
};

var flip = false;

//- var projection = mat4.create(); 
var uProjection, uModelview, uNormalMatrix;
var uFrontMaterial, uBackMaterial;
var lit,uLit, uTwoSided, uGlobalAmbient;
//- var rotator;

function createProgram(gl, vertexShaderSource, fragmentShaderSource) {
   var vsh = gl.createShader( gl.VERTEX_SHADER );
   gl.shaderSource(vsh,vertexShaderSource);
   gl.compileShader(vsh);
   if ( ! gl.getShaderParameter(vsh, gl.COMPILE_STATUS) ) {
      throw "Error in vertex shader:  " + gl.getShaderInfoLog(vsh);
   }
   var fsh = gl.createShader( gl.FRAGMENT_SHADER );
   gl.shaderSource(fsh, fragmentShaderSource);
   gl.compileShader(fsh);
   if ( ! gl.getShaderParameter(fsh, gl.COMPILE_STATUS) ) {
      throw "Error in fragment shader:  " + gl.getShaderInfoLog(fsh);
   }
   var prog = gl.createProgram();
   gl.attachShader(prog,vsh);
   gl.attachShader(prog, fsh);
   gl.linkProgram(prog);
   if ( ! gl.getProgramParameter( prog, gl.LINK_STATUS) ) {
      throw "Link error in program:  " + gl.getProgramInfoLog(prog);
   }
   return prog;
}

var veryGoodShader = new GL.Shader('\
     attribute vec3 coords;\
     attribute vec3 normal;\
     uniform mat4 modelview;\
     uniform mat4 projection;\
     varying vec3 viewCoords;\
     varying vec3 vNormal;\
     void main() {\
        vec4 tcoords = modelview*vec4(coords,1.0);\
        viewCoords = tcoords.xyz;\
        gl_Position = projection * tcoords;\
        vNormal = normal;\
     }\
', '\
     precision mediump float;\
     struct materialProperties {\
        vec3 ambient;\
        vec3 diffuse;\
        vec3 specular;\
        vec3 emissive;\
        float shininess;\
     };\
     struct lightProperties {\
        vec4 position;\
        vec3 intensity;\
        vec3 ambient;\
        bool enabled;\
     };\
     uniform materialProperties frontMaterial;\
     uniform materialProperties backMaterial;\
     materialProperties material;\
     uniform bool twoSided;\
     uniform mat3 normalMatrix;\
     uniform lightProperties light[4];\
     uniform bool lit;\
     uniform vec3 globalAmbient;\
     varying vec3 viewCoords;\
     varying vec3 vNormal;\
     \
     vec3 lighting(vec3 vertex, vec3 V, vec3 N) {\
        vec3 color = material.emissive + material.ambient * globalAmbient;\
        for (int i = 0; i < 1; i++) {\
            if (light[i].enabled) {\
                color += material.ambient * light[i].ambient;\
                vec3 L;\
                if (light[i].position.w == 0.0)\
                   L = normalize( light[i].position.xyz );\
                else\
                   L = normalize( light[i].position.xyz/light[i].position.w - vertex );\
                if ( dot(L,N) > 0.0) {\
                   vec3 R;\
                   R = (2.0*dot(N,L))*N - L;\
                   color += dot(N,L)*(light[i].intensity*material.diffuse);\
                   if ( dot(V,R) > 0.0)\
                      color += pow(dot(V,R),material.shininess) * (light[i].intensity * material.specular);\
                }\
            }\
        }\
        return color;\
     }\
\
     void main() {\
        if (lit) {\
           vec3 tnormal = normalize(normalMatrix*vNormal);\
           if (!gl_FrontFacing)\
               tnormal = -tnormal;\
           if ( gl_FrontFacing || !twoSided)\
              material = frontMaterial;\
           else\
              material = backMaterial;\
           gl_FragColor = vec4( lighting(viewCoords, normalize(-viewCoords),tnormal), 1.0 );\
        }\
        else {\
           if ( gl_FrontFacing || !twoSided )\
               gl_FragColor = vec4(frontMaterial.diffuse, 1.0);\
           else\
               gl_FragColor = vec4(backMaterial.diffuse, 1.0);\
        }\
     }\
');

var prog = gl.createProgram(gl,'\
     attribute vec3 coords;\
     attribute vec3 normal;\
     uniform mat4 modelview;\
     uniform mat4 projection;\
     varying vec3 viewCoords;\
     varying vec3 vNormal;\
     void main() {\
        vec4 tcoords = modelview*vec4(coords,1.0);\
        viewCoords = tcoords.xyz;\
        gl_Position = projection * tcoords;\
        vNormal = normal;\
     }\
', '\
     precision mediump float;\
     struct materialProperties {\
        vec3 ambient;\
        vec3 diffuse;\
        vec3 specular;\
        vec3 emissive;\
        float shininess;\
     };\
     struct lightProperties {\
        vec4 position;\
        vec3 intensity;\
        vec3 ambient;\
        bool enabled;\
     };\
     uniform materialProperties frontMaterial;\
     uniform materialProperties backMaterial;\
     materialProperties material;\
     uniform bool twoSided;\
     uniform mat3 normalMatrix;\
     uniform lightProperties light[4];\
     uniform bool lit;\
     uniform vec3 globalAmbient;\
     varying vec3 viewCoords;\
     varying vec3 vNormal;\
     \
     vec3 lighting(vec3 vertex, vec3 V, vec3 N) {\
        vec3 color = material.emissive + material.ambient * globalAmbient;\
        for (int i = 0; i < 4; i++) {\
            if (light[i].enabled) {\
                color += material.ambient * light[i].ambient;\
                vec3 L;\
                if (light[i].position.w == 0.0)\
                   L = normalize( light[i].position.xyz );\
                else\
                   L = normalize( light[i].position.xyz/light[i].position.w - vertex );\
                if ( dot(L,N) > 0.0) {\
                   vec3 R;\
                   R = (2.0*dot(N,L))*N - L;\
                   color += dot(N,L)*(light[i].intensity*material.diffuse);\
                   if ( dot(V,R) > 0.0)\
                      color += pow(dot(V,R),material.shininess) * (light[i].intensity * material.specular);\
                }\
            }\
        }\
        return color;\
     }\
\
     void main() {\
        if (lit) {\
           vec3 tnormal = normalize(normalMatrix*vNormal);\
           if (!gl_FrontFacing)\
               tnormal = -tnormal;\
           if ( gl_FrontFacing || !twoSided)\
              material = frontMaterial;\
           else\
              material = backMaterial;\
           gl_FragColor = vec4( lighting(viewCoords, normalize(-viewCoords),tnormal), 1.0 );\
        }\
        else {\
           if ( gl_FrontFacing || !twoSided )\
               gl_FragColor = vec4(frontMaterial.diffuse, 1.0);\
           else\
               gl_FragColor = vec4(backMaterial.diffuse, 1.0);\
        }\
     }\
');

/**
 *  Gets attribute and uniform locations and initializes uniform variables.
 */
function setUpAttribsAndUniforms() {
   aCoords = gl.getAttribLocation(prog,"coords");
   aNormal = gl.getAttribLocation(prog,"normal");
   uProjection = gl.getUniformLocation(prog,"projection");
   uModelview = gl.getUniformLocation(prog,"modelview");
   uNormalMatrix = gl.getUniformLocation(prog,"normalMatrix");
   uLit = gl.getUniformLocation(prog,"lit");
   uTwoSided = gl.getUniformLocation(prog,"twoSided");
   uGlobalAmbient = gl.getUniformLocation(prog,"globalAmbient");
   uFrontMaterial = {};
   uFrontMaterial.ambient = gl.getUniformLocation(prog,"frontMaterial.ambient");
   uFrontMaterial.diffuse = gl.getUniformLocation(prog,"frontMaterial.diffuse");
   uFrontMaterial.specular = gl.getUniformLocation(prog,"frontMaterial.specular");
   uFrontMaterial.emission = gl.getUniformLocation(prog,"frontMaterial.emissive");
   uFrontMaterial.shininess = gl.getUniformLocation(prog,"frontMaterial.shininess");
   uBackMaterial = {};
   uBackMaterial.ambient = gl.getUniformLocation(prog,"backMaterial.ambient");
   uBackMaterial.diffuse = gl.getUniformLocation(prog,"backMaterial.diffuse");
   uBackMaterial.specular = gl.getUniformLocation(prog,"backMaterial.specular");
   uBackMaterial.emission = gl.getUniformLocation(prog,"backMaterial.emissive");
   uBackMaterial.shininess = gl.getUniformLocation(prog,"backMaterial.shininess");
   uLight = [];
   for (var i = 0; i < 4; i++) {
       uLight[i] = {};
       uLight[i].position = gl.getUniformLocation(prog,"light[" + i + "].position");
       uLight[i].intensity = gl.getUniformLocation(prog,"light[" + i + "].intensity");
       uLight[i].ambient = gl.getUniformLocation(prog,"light[" + i + "].ambient");
       uLight[i].enabled = gl.getUniformLocation(prog,"light[" + i + "].enabled");
   }
   var identity4 = mat4.create();
   gl.uniformMatrix4fv(uProjection, false, identity4);
   gl.uniformMatrix4fv(uModelview, false, identity4);
   var identity3 = mat3.create();
   gl.uniformMatrix3fv(uNormalMatrix, false, identity3);
   gl.uniform1i(uLit, 1);
   gl.uniform1i(uTwoSided, 0);
   gl.uniform3f(uGlobalAmbient, 1, 1, 1);
   gl.uniform3f(uFrontMaterial.ambient, 0.1, 0.1, 0.1);
   gl.uniform3f(uFrontMaterial.diffuse, 0.6, 0.6, 0.6);
   gl.uniform3f(uFrontMaterial.specular, 0.3, 0.3, 0.3);
   gl.uniform3f(uFrontMaterial.emission, 0, 0, 0);
   gl.uniform1f(uFrontMaterial.shininess, 50);
   gl.uniform3f(uBackMaterial.ambient, 0.1, 0.1, 0.1);
   gl.uniform3f(uBackMaterial.diffuse, 0.3, 0.6, 0.6);
   gl.uniform3f(uBackMaterial.specular, 0.3, 0.3, 0.3);
   gl.uniform3f(uBackMaterial.emission, 0, 0, 0);
   gl.uniform1f(uBackMaterial.shininess, 50);
   for (i = 0; i < 4; i++) {
       gl.uniform4f(uLight[i].position, 0, 0, 1, 0);
       gl.uniform3f(uLight[i].ambient, 0, 0, 0);
       if (i == 0) {
           gl.uniform3f(uLight[i].intensity, 1, 1, 1);
           gl.uniform1i(uLight[i].enabled, 1);
       }
       else {
           gl.uniform3f(uLight[i].intensity, 0, 0, 0);
           gl.uniform1i(uLight[i].enabled, 0);
       }
    }
}

    gl.useProgram(prog);

    setUpAttribsAndUniforms();

function createModel(modelData) {
    var model = {};
    model.coordsBuffer = gl.createBuffer();
    model.normalBuffer = gl.createBuffer();
    model.indexBuffer = gl.createBuffer();
    model.count = modelData.triangles.length;
    gl.bindBuffer(gl.ARRAY_BUFFER, model.coordsBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, modelData.vertices, gl.STATIC_DRAW);
    gl.bindBuffer(gl.ARRAY_BUFFER, model.normalBuffer);
    gl.bufferData(gl.ARRAY_BUFFER, modelData.normals, gl.STATIC_DRAW);
    gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, model.indexBuffer);
    gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, modelData.triangles, gl.STATIC_DRAW);
    model.render = function() {  // This function will render the object.
        gl.bindBuffer(gl.ARRAY_BUFFER, this.coordsBuffer);
        gl.vertexAttribPointer(aCoords, 3, gl.FLOAT, false, 0, 0);
        gl.bindBuffer(gl.ARRAY_BUFFER, this.normalBuffer);
        gl.vertexAttribPointer(aNormal, 3, gl.FLOAT, false, 0, 0);
        gl.uniformMatrix4fv(uModelview, false, modelview );
        mat3.normalFromMat4(normalMatrix, modelview);
        gl.uniformMatrix3fv(uNormalMatrix, false, normalMatrix);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, this.indexBuffer);
        gl.drawElements(gl.TRIANGLES, this.count, gl.UNSIGNED_SHORT, 0);
    }
    return model;
}

gl.ondraw = function() {
  gl.clearColor(0.9, 0.9, 0.9, 1);
  gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  gl.loadIdentity();
  gl.translate(0, 0, -8);
  gl.rotate(angleX, 1, 0, 0);
  gl.rotate(angleY, 0, 1, 0);
  gl.translate(0, -0.25, 0);
    gl.clearColor(0,0,0,1);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    GL.Matrix.perspective(Math.PI/3, 1, 1, 50, projection);
    gl.uniformMatrix4fv(uProjection, false, projection);

    modelview = gl.modelviewMatrix;

    var saveMV = mat4.clone(modelview);
    
    var pos = GL.Vector.randomDirection(); // For setting the light positions
    
    gl.uniform3f(uFrontMaterial.specular, 1,1,1);  // Only the teapot will have specular reflection.

  // Alternate between a shadow from a random point on the sky hemisphere
  // and a random point near the light (creates a soft shadow)
  //- var dir = GL.Vector.randomDirection();
  //- flip = !flip;
  //- if (flip) dir = new GL.Vector(1, 1, 1).add(dir.multiply(0.3 * Math.sqrt(Math.random()))).unit();
  //- quadMesh.drawShadow(dir.y < 0 ? dir.negative() : dir);

  // Draw the mesh with the ambient occlusion so far
  //- quadMesh.lightmapTexture.bind();
  //- textureMapShader.draw(mesh);
  //- gl.enable(gl.POLYGON_OFFSET_FILL);
  //- console.log("number of meshes : "+meshes.length);
  //- for (var i = 0; i < meshes.length; i++) veryGoodShader.draw(meshes[i]);
  //- gl.disable(gl.POLYGON_OFFSET_FILL);
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