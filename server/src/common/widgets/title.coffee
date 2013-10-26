handlebars = require('handlebars')
Widget = require('./widget').Widget

class Title extends Widget

    @header: handlebars.compile '<{{element}} data-field-type="title" data-placeholder="Title goes here..." data-fieldname-title="{{titleField}}">{{title}}</{{element}}>'


    @headerWithLink: handlebars.compile '<{{element}} data-field-type="title" data-placeholder="Title goes here..." data-fieldname-title="{{titleField}}"><a href="{{link}}">{{title}}</a></{{element}}>'


    constructor: (@params) ->
        @params.title ?= '@title'
        @params.link ?= '@link'
        @params.titleField ?= 'title'
        @params.titleSize ?= 2
        
    render: (data) =>
        title = @parseExpression @params.title, data
        link = @parseExpression @params.link, data
        element = "h" + parseInt(@params.titleSize)
        
        if @link
            Title.header { title, element, fieldTitle: @params.titleField }
        else
            Title.headerWithLink { title, link, element, titleField: @params.titleField }
            
    
exports.Title = Title
