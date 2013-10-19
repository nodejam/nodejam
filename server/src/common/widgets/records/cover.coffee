handlebars = require('handlebars')
Widget = require '../widget'

class Cover extends Widget

    @template: handlebars.compile '<img class="cover" src="{{src}}" alt="{{alt}}" data-field-type="cover" data-fieldname-src={{fieldSrc}} data-fieldname-alt={{fieldAlt}} />'



    constructor: (@fields = {}) ->
        @fields.src ?= 'cover'
        @fields.alt ?= 'coverAlt'
       
       
        
    render: (data) =>
        src = data.record[@fields.src]
        alt = data.record[@fields.alt]
        Cover.template { src, alt, fieldSrc: @fields.src, fieldAlt: @fields.alt }        

    
exports.Cover = Cover
