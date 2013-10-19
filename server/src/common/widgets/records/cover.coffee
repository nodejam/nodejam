handlebars = require('handlebars')
Widget = require '../widget'

class Cover extends Widget

    @template: handlebars.compile '<img class="cover" src="{{src}}" alt="{{alt}}" data-field-type="cover" data-fieldname-src={{fieldSrc}} data-fieldname-alt={{fieldAlt}} />'



    constructor: (@fields = {}) ->
        @fields.cover ?= 'cover'
       
       
        
    render: (data) =>
        src = data.record[@fields.cover].image
        alt = data.record[@fields.cover].alt
        Cover.template { src, alt, fieldSrc: "#{@fields.cover}_image", fieldAlt: "#{@fields.cover}_alt" }        

    
exports.Cover = Cover
