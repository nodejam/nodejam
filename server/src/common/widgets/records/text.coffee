handlebars = require('handlebars')
Widget = require('../widget').Widget

class Text extends Widget
    
    @template = handlebars.compile '
        <div class="content" data-field-type="text" data-fieldname-text="{{fieldText}}" data-placeholder="Start typing content...">
            {{{text}}}
        </div>'
    
        

    constructor: (params = {}) ->
        @fields = params.fields ? {}
        @fields.text ?= 'content'
       
        
    render: (data) =>
        text = @getValue(data.record, @fields.text).formatContent()
        Text.template { text, fieldText: @fields.text }

    
exports.Text = Text


