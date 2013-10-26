handlebars = require('handlebars')
Widget = require('./widget').Widget

class Image extends Widget

    @template: handlebars.compile '
        <img src="{{src}}" alt="{{alt}}"/>'

    
    @bgTemplate: handlebars.compile '
        <div class="image" style="background-image:url({{src}})"></div>'


    @editableTemplate: handlebars.compile '
        <img src="{{src}}" alt="{{alt}}" data-field-type="image" data-fieldname-src={{srcField}} data-fieldname-alt={{altField}}/>'
        
        
    @emptyEditableTemplate: handlebars.compile '
        <div class="image" data-field-type="image" data-fieldname-src={{srcField}} data-fieldname-alt={{altField}}></div>'


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
                Image.editableTemplate { src, alt, srcField: "#{image}_src", altField: "#{image}_alt" }        
            else
                Image.emptyEditableTemplate {}
        else
            if @params.bg
                if image then Image.bgTemplate { src, alt } else ''
            else
                if image then Image.template { src, alt } else ''
                
            
    
exports.Image = Image



