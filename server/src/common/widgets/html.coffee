handlebars = require('handlebars')
Widget = require('./widget').Widget

class Html extends Widget
    
    constructor: (@params) ->
       
        
    render: (data) =>
        @params.html

    
exports.Html = Html

