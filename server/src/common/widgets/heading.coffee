handlebars = require('handlebars')
Widget = require('./widget').Widget

class Heading extends Widget

    @header: handlebars.compile '<{{element}} {{attr}}">{{title}}</{{element}}>'


    @headerWithLink: handlebars.compile '<{{element}} {{attr}}"><a href="{{link}}">{{title}}</a></{{element}}>'


    constructor: (@params) ->
        
        
    render: (data) =>
        title = @parseExpression @params.title, data
        link = @parseExpression @params.link, data
        
        element = "h" + parseInt(@params.size)
        
        attribs = {}
        
        if @params.class
            attribs.class = @params.class

        if @params.field
            attribs['data-field-type'] = 'text'
            attribs['data-field-name'] = @params.field
            attribs['data-placeholder'] = "Title goes here..."   

        attr = @toAttributes(attribs)                 
        
        if not link
            Heading.header { title, element, attr }
        else
            Heading.headerWithLink { title, link, element, attr }
            
    
exports.Heading = Heading
