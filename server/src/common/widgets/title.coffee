handlebars = require('handlebars')
Widget = require('./widget').Widget

class Title extends Widget

    @header: handlebars.compile '<{{element}} data-placeholder="Title goes here..." data-fieldname="{{field}}">{{title}}</{{element}}>'


    @headerWithLink: handlebars.compile '<{{element}} data-placeholder="Title goes here..." data-fieldname="{{field}}"><a href="{{link}}">{{title}}</a></{{element}}>'


    constructor: (@params) ->
        
        
    render: (data) =>
        title = @parseExpression @params.title, data
        link = @parseExpression @params.link, data
        
        element = "h" + parseInt(@params.size)
        
        if not link
            Title.header { title, element, field: @params.field }
        else
            Title.headerWithLink { title, link, element, field: @params.field }
            
    
exports.Title = Title
