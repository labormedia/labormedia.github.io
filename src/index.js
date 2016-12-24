var riot = require('riot')
// riot.M = require('gl-matrix')
require('./tags/templar.tag')
// require('./tags/templar-tests.tag')
require('./tags/parameter-ui.tag')
// require('./libraries/gl-matrix.js')

// require("babel-core").transform("code", {
//   plugins: ["transform-runtime"]
// });
require.ensure(['./tags/templar.tag'], function(require){
    // require('./libraries/lightgl/main.js');
    require('./models/param_test005.js');
});

require.ensure(['./tags/templar.tag'], function(require){
    require('./libraries/lightgl/main.js');
    // require('./models/param_test005.js');
});

// require.ensure(['./libraries/sim/common.js'], function(require){
//     require('./libraries/lightgl/main.js');
// });

// require.ensure(['./libraries/lightgl/main.js'], function(require){
//     require('./libraries/lightgl/matrix.js');
//     require('./libraries/lightgl/mesh.js');
//     require('./libraries/lightgl/raytracer.js');
//     require('./libraries/lightgl/shader.js');
//     require('./libraries/lightgl/texture.js');
//     require('./libraries/lightgl/vector.js');
// });


// riot.cloneObject = function(obj) {
//     // A clone of an object is an empty object 
//             // with a prototype reference to the original.

//     // a private constructor, used only by this one clone.
//     function Clone() { } 
//     Clone.prototype = obj;
//     var c = new Clone();
//             c.constructor = Clone;
//             return c;
// }

document.addEventListener('DOMContentLoaded', function(){
    riot.mount('templar')
    // riot.mount('templar-tests')
    riot.mount('parameter-ui')
})


