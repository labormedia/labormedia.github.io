var riot = require('riot')
require('./tags/templar.tag')

document.addEventListener('DOMContentLoaded', function(){
    riot.mount('templar')
})