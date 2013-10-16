handlebars = require('handlebars')
Widget = require '../widget'

class Cover extends Widget

    @template: handlebars.compile '<img class="cover" src="{{src}}" alt="{{alt}}" data-editor="type:image" />'



    constructor: (@cover = 'cover', @alt = 'coverAlt') ->
       
       
        
    render: (data) =>
        src = data.record[@cover]
        alt = data.record[@alt]
        Cover.template { src, alt }        

    
exports.Cover = Cover
