var riot = require('riot')
require('./tags/templar.tag')
require('./tags/parameter-ui.tag')

document.addEventListener('DOMContentLoaded', function(){
    riot.mount('templar')
    riot.mount('parameter-ui')
})