handlebars = require('handlebars')
Widget = require '../widget'

class Content extends Widget
    
    @template = handlebars.compile '
        <div class="content" data-field-type="content" data-field-content="{{field}}">
            {{{content}}}
        </div>'
    
        

    constructor: (@content = 'content') ->
        
       
        
    render: (data) =>
        content = data.record.formatField @content
        Content.template { content, field: @content }

    
exports.Content = Content


