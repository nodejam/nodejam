handlebars = require('handlebars')
Widget = require('./widget').Widget

class Text extends Widget
    
    @template = handlebars.compile '
        <div class="content" data-field-type="text" data-fieldname-text="{{textField}}" data-placeholder="Start typing content...">
            {{{text}}}
        </div>'
    
        

    constructor: (@params) ->
       
        
    render: (data) =>
        text = @parseExpression(@params.text, data).formatContent()
        Text.template { text, textField: @params.textField }

    
exports.Text = Text


