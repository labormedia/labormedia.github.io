var riot = require('riot')
require('./tags/templar.tag')
require('./tags/parameter-ui.tag')

// require("babel-core").transform("code", {
//   plugins: ["transform-runtime"]
// });
require.ensure(['./tags/templar.tag'], function(require){
    require('./models/param_test005.js');
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
riot.mixin('target', mixinObject)
document.addEventListener('DOMContentLoaded', function(){
    var mixinObject = null;

    riot.mount('templar')
    // riot.mount('templar-tests')
    riot.mount('parameter-ui')
})


