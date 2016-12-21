function TriangleMesh(numTriangles, texelsPerSide) {
  this.size = numTriangles;
  this.texelsPerSide = texelsPerSide;
  this.mesh = new GL.Mesh({ normals: true, coords: true });
  this.index = 0;
  this.lightmapTexture = null;
  this.bounds = null;
  this.sampleCount = 0;

  // Also need values offset by 0.5 texels to avoid seams between lightmap cells
  // this.mesh.addVertexBuffer('offsetCoords', 'offsetCoord');
  // this.mesh.addVertexBuffer('offsetPositions', 'offsetPosition');
};

TriangleMesh.prototype.addVertices = function(vertices) {
  // this.mesh.vertices.push(a.toArray());
  // this.mesh.vertices.push(b.toArray());
  // this.mesh.vertices.push(c.toArray());

  // this.mesh.normals.push(n1.toArray());
  // this.mesh.normals.push(n2.toArray());
  // this.mesh.normals.push(n3.toArray());
  this.mesh.vertices = vertices;

};

TriangleMesh.prototype.addNormals = function(normals) {
  this.mesh.normals = normals;

};

// Add a quad given its four vertices and allocate space for it in the lightmap
TriangleMesh.prototype.addTriangle = function(t1, t2, t3) {
  // Add triangle
  this.mesh.triangles.push([t1, t2, t3])
};

TriangleMesh.prototype.addTriangles = function(triangles) {
  // Add triangle
  this.mesh.triangles = triangles;
};

TriangleMesh.prototype.addDoubleTriangles = function(triangles) {
  // Add Double triangles
  this.mesh.triangles = triangles;
  // for (var i = 0; i < triangles.length; i++) {
  //   this.addTriangle(triangles[i][0], triangles[i][2], triangles[i][1])
  // }

};

TriangleMesh.prototype.addDoubleTriangle = function(t1, t2, t3) {
  // Need a separate lightmap for each side of the quad
  this.addTriangle(t1, t2, t3);
  this.addTriangle(t1, t3, t2);
};

TriangleMesh.prototype.compile = function() {
  // Finalize mesh
  this.mesh.compile();
  this.bounds = this.mesh.getBoundingSphere();

  // Create textures
  // var size = this.size * this.texelsPerSide;
  // this.lightmapTexture = new GL.Texture(size, size, { format: gl.RED, type: gl.FLOAT });
};

// QuadMesh.prototype.drawShadow = function(dir) {
  // Construct a camera looking from the light toward the object
  // var r = this.bounds.radius, c = this.bounds.center;
  // gl.matrixMode(gl.PROJECTION);
  // gl.pushMatrix();
  // gl.loadIdentity();
  // gl.ortho(-r, r, -r, r, -r, r);
  // gl.matrixMode(gl.MODELVIEW);
  // gl.pushMatrix();
  // gl.loadIdentity();
  // var at = c.subtract(dir);
  // var useY = (dir.max() != dir.y);
  // var up = new GL.Vector(!useY, useY, 0).cross(dir);
  // gl.lookAt(c.x, c.y, c.z, at.x, at.y, at.z, up.x, up.y, up.z);

  // Render the object viewed from the light using a shader that returns the fragment depth
  // var mesh = this.mesh;
  // var shadowMapMatrix = gl.projectionMatrix.multiply(gl.modelviewMatrix);
  // depthMap.drawTo(function() {
  //   gl.clearColor(1, 1, 1, 1);
  //   gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
  //   depthShader.draw(mesh);
  // });

  // Reset the transform
  // gl.matrixMode(gl.PROJECTION);
  // gl.popMatrix();
  // gl.matrixMode(gl.MODELVIEW);
  // gl.popMatrix();

  // Run the shadow test for each texel in the lightmap and
  // accumulate that onto the existing lightmap contents
//   var sampleCount = this.sampleCount++;
//   depthMap.bind();
//   this.lightmapTexture.drawTo(function() {
//     gl.enable(gl.BLEND);
//     gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
//     shadowTestShader.uniforms({
//       shadowMapMatrix: shadowMapMatrix,
//       sampleCount: sampleCount,
//       light: dir
//     }).draw(mesh);
//     gl.disable(gl.BLEND);
//   });
//   depthMap.unbind();
// };