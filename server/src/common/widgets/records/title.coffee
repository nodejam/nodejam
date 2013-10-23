handlebars = require('handlebars')
Widget = require('../widget').Widget

class Title extends Widget

    @template: handlebars.compile '<h1 data-field-type="title" data-placeholder="Title goes here..." data-fieldname-title="{{fieldTitle}}">{{title}}</h1>'



    constructor: (params = {}) ->
        @fields = params.fields ? {}
        @fields.title ?= 'title'
       
        
        
    render: (data) =>
        title = @getValue data.record, @fields.title
        Title.template { title, fieldTitle: @fields.title }        

    
exports.Title = Title
