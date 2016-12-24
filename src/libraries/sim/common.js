import { GL } from '../lightgl/main';
import { Vector } from '../lightgl/vector';


export function SIM (numMeshes) {
  this.meshes = [];
  this.meshes_i = [];
  // centroid define el grupo de elementos estructurales
  this.centroid = function (newVec3) {
    // console.log(newVec3 instanceof GL.Vector);
    if (newVec3 instanceof GL.Vector) {
      this.centersum = this.centersum.add(newVec3); 
      // console.log(this.centersum) ; 
      this.centers.push(newVec3);
    } else {
      return this.centersum.multiply(1/this.centers.length);
    }
  };
  this.size = numMeshes;
  // propiedades de this.centroid()
  this.centers = [];
  this.centersum = new GL.Vector(0,0,0);

}



  //- centers.sum = new GL.Vector(0,0,0);