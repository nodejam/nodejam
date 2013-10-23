handlebars = require('handlebars')
Widget = require('../widget').Widget

class Image extends Widget

    @template: handlebars.compile '
        <img src="{{src}}" alt="{{alt}}" {{#if class}}class="{{class}}" {{/if}}/>'


    @editableTemplate: handlebars.compile '
        <div {{#if class}}class="{{class}}" {{/if}}data-field-type="image" data-fieldname-src={{fieldSrc}} data-fieldname-alt={{fieldAlt}}>
            <img src="{{src}}" alt="{{alt}}" />
        </div>'
        
        
    @emptyEditableTemplate: handlebars.compile '
        <div class="image" data-field-type="image" data-fieldname-src={{fieldSrc}} data-fieldname-alt={{fieldAlt}}></div>'


    constructor: (params = {}) ->
        @fields = params.fields ? {}       
        @klass = params.class
        @editable = params.editable ? false
        
        
    render: (data) =>
        image = @getValue data.record, @fields.image

        if image
            src = image.src
            alt = image.alt
            caption = image.caption

        if @editable        
            if image
                Image.editableTemplate { src, alt, class: @klass, fieldSrc: "#{@fields.image}_src", fieldAlt: "#{@fields.image}_alt" }        
            else
                Image.emptyEditableTemplate {}
        else
            if image then Image.template { src, alt, class: @klass } else ''
                
            
    
exports.Image = Image
