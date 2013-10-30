handlebars = require('handlebars')
Widget = require('./widget').Widget

class Image extends Widget

    @template: handlebars.compile '
        <img src="{{src}}" alt="{{alt}}" {{attr}}/>'

    
    @bgTemplate: handlebars.compile '
        <div style="background-image:url({{src}})" {{attr}}></div>'


    @editableTemplate: handlebars.compile '
        <img src="{{src}}" alt="{{alt}}" {{attr}}/>'
        
        
    @emptyEditableTemplate: handlebars.compile '
        <div class="image" {{attr}}></div>'


    constructor: (@params) ->
        
        
    render: (data) =>
        image = @parseExpression @params.image, data

        if image
            if @params.type isnt 'small'
                src = image.src
            else
                src = image.small
            alt = image.alt
            caption = image.caption
        
        attribs = {}

        if @params.bg
            attribs.class = 'image'

        if @params.class
            attribs.class = @params.class

        if @params.field
            attribs['data-field-type'] = 'image'
            attribs['data-field-name'] = @params.field
        
        attr = @toAttributes(attribs)
        
        if @params.editable        
            if image
                Image.editableTemplate { src, alt, attr }        
            else
                Image.emptyEditableTemplate {}
        else
            if @params.bg
                if image then Image.bgTemplate { src, alt, attr } else ''
            else
                if image then Image.template { src, alt, attr } else ''
                
            
    
exports.Image = Image



