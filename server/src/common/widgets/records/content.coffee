handlebars = require('handlebars')
Widget = require '../widget'

class Content extends Widget
    
    @template = handlebars.compile '
        <div class="content" data-placeholder="And record content goes here..." data-editor-type="text">
            {{{content}}}
        </div>'
    
        

    constructor: (@content = 'content') ->
        
       
        
    render: (data) =>
        content = data.record.formatField @content
        Content.template { content }

    
exports.Content = Content


