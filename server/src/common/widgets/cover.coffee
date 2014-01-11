handlebars = require('handlebars')
Widget = require('./widget').Widget

class Cover extends Widget

    @template: handlebars.compile '<img {{{attr}}} src="{{src}}" alt="{{alt}}" />'

    
    @bgTemplate: handlebars.compile '<div style="background-image:url({{src}})" {{{attr}}}></div>'


    @emptyTemplate: handlebars.compile '<div {{{attr}}}></div>'


    constructor: (@params) ->
        
        
    render: (data) =>
        cover = @parseExpression @params.cover, data

        if cover?.image
            if @params.type isnt 'small'
                src = cover.image.src
            else
                src = cover.image.small
            alt = cover.image.alt
        
        attribs = {}

        if @params.class
            attribs['class'] = @params.class
        else
            attribs['class'] = 'cover'

        if @params.field
            attribs['data-field-type'] = 'cover'
            attribs['data-field-name'] = @params.field
            attribs['data-cover-format'] = 'normal,top,full'
            if cover?.image
                attribs['data-small-image'] = cover.image.small

        attr = @toAttributes(attribs)
        
        if @params.editable        
            if cover?.image
                Cover.template { src, alt, attr }        
            else
                Cover.emptyTemplate { attr }
        else
            if @params.bg
                if cover?.image then Cover.bgTemplate { src, alt, attr } else ''
            else
                if cover?.image then Cover.template { src, alt, attr } else ''
                
            
    
exports.Cover = Cover



