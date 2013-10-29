handlebars = require('handlebars')
Widget = require('./widget').Widget

class Image extends Widget

    @template: handlebars.compile '
        <img{{#if class}} class="{{class}}"{{/if}} src="{{src}}" alt="{{alt}}"/>'

    
    @bgTemplate: handlebars.compile '
        <div class="image" style="background-image:url({{src}})"></div>'


    @editableTemplate: handlebars.compile '
        <img{{#if class}} class="{{class}}"{{/if}} src="{{src}}" alt="{{alt}}" data-fieldname={{field}} />'
        
        
    @emptyEditableTemplate: handlebars.compile '
        <div class="image" data-fieldname={{field}}></div>'


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

        if @params.editable        
            if image
                Image.editableTemplate { src, alt, field: @params.field, class: @params.class }        
            else
                Image.emptyEditableTemplate {}
        else
            if @params.bg
                if image then Image.bgTemplate { src, alt } else ''
            else
                if image then Image.template { src, alt, class: @params.class } else ''
                
            
    
exports.Image = Image



