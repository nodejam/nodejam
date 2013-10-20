handlebars = require('handlebars')
Widget = require '../widget'

class Cover extends Widget

    @template: handlebars.compile '
        <div class="cover" data-field-type="cover" data-fieldname-src={{fieldSrc}} data-fieldname-alt={{fieldAlt}}>
            <img src="{{src}}" alt="{{alt}}" />
        </div>'

    @emptyTemplate: handlebars.compile '
        <div class="cover" data-field-type="cover" data-fieldname-src={{fieldSrc}} data-fieldname-alt={{fieldAlt}}></div>'


    constructor: (@fields = {}) ->
        @fields.cover ?= 'cover'
        
       
        
    render: (data) =>
        cover = data.record[@fields.cover]
        
        if cover
            src = cover.image
            alt = cover.alt
            caption = cover.caption
            Cover.template { src, alt, fieldSrc: "#{@fields.cover}_image", fieldAlt: "#{@fields.cover}_alt" }        
        else
            Cover.emptyTemplate {}

    
exports.Cover = Cover
