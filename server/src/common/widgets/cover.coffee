handlebars = require('handlebars')
Widget = require('./widget').Widget

class Cover extends Widget

    @header: handlebars.compile '<{{element}} {{{attr}}}">{{title}}</{{element}}>'

    constructor: (@params) ->
        
        
        
    render: (data) =>
        cover = @parseExpression @params.cover, data

        if cover
            if cover.type
                cover.classes = "with-cover #{cover.type}"
            else
                cover.classes = "with-cover auto-cover"
            
            if @params.editable
                cover.field = @params.field            
        
        { cover }
        
    
exports.Cover = Cover
