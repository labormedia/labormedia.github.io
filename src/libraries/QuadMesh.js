function QuadMesh(numQuads, texelsPerSide) {
  this.size = Math.ceil(Math.sqrt(numQuads));
  this.texelsPerSide = texelsPerSide;
  this.mesh = new GL.Mesh({ normals: true, coords: true });
  this.index = 0;
  this.lightmapTexture = null;
  this.bounds = null;
  this.sampleCount = 0;

  // Also need values offset by 0.5 texels to avoid seams between lightmap cells
  this.mesh.addVertexBuffer('offsetCoords', 'offsetCoord');
  this.mesh.addVertexBuffer('offsetPositions', 'offsetPosition');
}

// Add a quad given its four vertices and allocate space for it in the lightmap
QuadMesh.prototype.addQuad = function(a, b, c, d) {
  var half = 0.5 / this.texelsPerSide;

  // Add vertices
  this.mesh.vertices.push(a.toArray());
  this.mesh.vertices.push(b.toArray());
  this.mesh.vertices.push(c.toArray());
  this.mesh.vertices.push(d.toArray());

  // Add normal
  var normal = b.subtract(a).cross(c.subtract(a)).unit().toArray();
  this.mesh.normals.push(normal);
  this.mesh.normals.push(normal);
  this.mesh.normals.push(normal);
  this.mesh.normals.push(normal);

  // Add fake positions
  function lerp(x, y) {
    return a.multiply((1-x)*(1-y)).add(b.multiply(x*(1-y)))
      .add(c.multiply((1-x)*y)).add(d.multiply(x*y)).toArray();
  }
  this.mesh.offsetPositions.push(lerp(-half, -half));
  this.mesh.offsetPositions.push(lerp(1 + half, -half));
  this.mesh.offsetPositions.push(lerp(-half, 1 + half));
  this.mesh.offsetPositions.push(lerp(1 + half, 1 + half));

  // Compute location of texture cell
  var i = this.index++;
  var s = i % this.size;
  var t = (i - s) / this.size;

  // Coordinates that are in the center of border texels (to avoid leaking)
  var s0 = (s + half) / this.size;
  var t0 = (t + half) / this.size;
  var s1 = (s + 1 - half) / this.size;
  var t1 = (t + 1 - half) / this.size;
  this.mesh.coords.push([s0, t0]);
  this.mesh.coords.push([s1, t0]);
  this.mesh.coords.push([s0, t1]);
  this.mesh.coords.push([s1, t1]);

  // Coordinates that are on the edge of border texels (to avoid cracks when rendering)
  var rs0 = s / this.size;
  var rt0 = t / this.size;
  var rs1 = (s + 1) / this.size;
  var rt1 = (t + 1) / this.size;
  this.mesh.offsetCoords.push([rs0, rt0]);
  this.mesh.offsetCoords.push([rs1, rt0]);
  this.mesh.offsetCoords.push([rs0, rt1]);
  this.mesh.offsetCoords.push([rs1, rt1]);

  // A quad is two triangles
  this.mesh.triangles.push([4 * i, 4 * i + 1, 4 * i + 3]);
  this.mesh.triangles.push([4 * i, 4 * i + 3, 4 * i + 2]);
};

QuadMesh.prototype.addDoubleQuad = function(a, b, c, d) {
  // Need a separate lightmap for each side of the quad
  this.addQuad(a, b, c, d);
  this.addQuad(a, c, b, d);
};

QuadMesh.prototype.compile = function() {
  // Finalize mesh
  this.mesh.compile();
  this.bounds = this.mesh.getBoundingSphere();

  // Create textures
  var size = this.size * this.texelsPerSide;
  this.lightmapTexture = new GL.Texture(size, size, { format: gl.RED, type: gl.FLOAT });
};

QuadMesh.prototype.drawShadow = function(dir) {
  // Construct a camera looking from the light toward the object
  var r = this.bounds.radius, c = this.bounds.center;
  gl.matrixMode(gl.PROJECTION);
  gl.pushMatrix();
  gl.loadIdentity();
  gl.ortho(-r, r, -r, r, -r, r);
  gl.matrixMode(gl.MODELVIEW);
  gl.pushMatrix();
  gl.loadIdentity();
  var at = c.subtract(dir);
  var useY = (dir.max() != dir.y);
  var up = new GL.Vector(!useY, useY, 0).cross(dir);
  gl.lookAt(c.x, c.y, c.z, at.x, at.y, at.z, up.x, up.y, up.z);

  // Render the object viewed from the light using a shader that returns the fragment depth
  var mesh = this.mesh;
  var shadowMapMatrix = gl.projectionMatrix.multiply(gl.modelviewMatrix);
  depthMap.drawTo(function() {
    gl.clearColor(1, 1, 1, 1);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);
    depthShader.draw(mesh);
  });

  // Reset the transform
  gl.matrixMode(gl.PROJECTION);
  gl.popMatrix();
  gl.matrixMode(gl.MODELVIEW);
  gl.popMatrix();

  // Run the shadow test for each texel in the lightmap and
  // accumulate that onto the existing lightmap contents
  var sampleCount = this.sampleCount++;
  depthMap.bind();
  this.lightmapTexture.drawTo(function() {
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
    shadowTestShader.uniforms({
      shadowMapMatrix: shadowMapMatrix,
      sampleCount: sampleCount,
      light: dir
    }).draw(mesh);
    gl.disable(gl.BLEND);
  });
  depthMap.unbind();
};