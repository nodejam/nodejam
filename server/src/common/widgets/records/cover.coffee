handlebars = require('handlebars')
Widget = require '../widget'

class Cover extends Widget

    @template: handlebars.compile '<img class="cover" src="{{src}}" alt="{{alt}}" data-field-type="cover" data-field-src={{fieldSrc}} data-field-alt={{fieldAlt}} />'



    constructor: (@src = 'cover', @alt = 'coverAlt') ->
       
       
        
    render: (data) =>
        src = data.record[@src]
        alt = data.record[@alt]
        Cover.template { src, alt, fieldSrc: @src, fieldAlt: @alt }        

    
exports.Cover = Cover
