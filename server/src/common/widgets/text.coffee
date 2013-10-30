handlebars = require('handlebars')
Widget = require('./widget').Widget

class Text extends Widget
    
    @template = handlebars.compile '
        <div class="content" {{attr}}>
            {{{text}}}
        </div>'
    
        

    constructor: (@params) ->
       
        
    render: (data) =>
        text = @parseExpression(@params.text, data).formatContent()
        
        attribs = {}

        if @params.class
            attribs.class = @params.class

        if @params.field
            attribs['data-field-type'] = 'text'
            attribs['data-field-name'] = @params.field
            attribs['data-placeholder'] = "Start typing content..."
        
        attr = @toAttributes(attribs)
        
        Text.template { text, attr }

    
exports.Text = Text


