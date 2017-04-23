var riot = require('riot');
require('./tags/templar.tag');
require('./tags/parameter-ui.tag');
require('./tags/fb-pixel.tag');
require('./tags/script-io.tag');

// require("babel-core").transform("code", {
//   plugins: ["transform-runtime"]
// });
require.ensure(['./tags/templar.tag'], function(require){
    require('./models/GHModel000.js');
});

require.ensure(['./tags/templar.tag'], function(require){
    require('./libraries/lightgl/main.js');
});

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
var mixinObject = {observable: riot.observable(),hello: "good", target: null, pov: -8};
// var manifestMixin = JSON.stringify(require('build-manifest.json'));
// console.log('love you '+MANIFEST);

// riot.mixin('MANIFEST',MANIFEST);
riot.mixin('target', mixinObject);
document.addEventListener('DOMContentLoaded', function(){
    riot.mount('script-io')
    var mixinObject = null;

    riot.mount('templar')
    // riot.mount('templar-tests')
    riot.mount('parameter-ui')
    riot.mount('fb-pixel')
})


