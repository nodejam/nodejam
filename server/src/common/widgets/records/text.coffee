handlebars = require('handlebars')
Widget = require '../widget'

class Text extends Widget
    
    @template = handlebars.compile '
        <div class="content" data-field-type="text" data-field-text="{{field}}" data-placeholder="Start typing content...">
            {{{text}}}
        </div>'
    
        

    constructor: (@fields = {}) ->
        @fields.text = 'content'
       
        
    render: (data) =>
        text = data.record.formatField @fields.text
        Text.template { text, field: @fields.text }

    
exports.Text = Text


