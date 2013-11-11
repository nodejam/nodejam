handlebars = require('handlebars')
Widget = require('./widget').Widget

class Image extends Widget

    @template: handlebars.compile '<img {{{attr}}} src="{{src}}" alt="{{alt}}" />'

    
    @bgTemplate: handlebars.compile '<div style="background-image:url({{src}})" {{{attr}}}></div>'


    @emptyTemplate: handlebars.compile '<div class="image" {{{attr}}}></div>'


    constructor: (@params) ->
        
        
    render: (data) =>
        image = @parseExpression @params.image, data

        if image
            if @params.type isnt 'small'
                src = image.src
            else
                src = image.small
            alt = image.alt
        
        attribs = {}

        if @params.class
            attribs['class'] = @params.class
        else
            attribs['class'] = 'image'

        if @params.field
            attribs['data-field-type'] = 'image'
            attribs['data-field-name'] = @params.field
            if image
                attribs['data-small-image'] = image.small

        attr = @toAttributes(attribs)
        
        if @params.editable        
            if image
                Image.template { src, alt, attr }        
            else
                Image.emptyTemplate { attr }
        else
            if @params.bg
                if image then Image.bgTemplate { src, alt, attr } else ''
            else
                if image then Image.template { src, alt, attr } else ''
                
            
    
exports.Image = Image



