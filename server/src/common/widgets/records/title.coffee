handlebars = require('handlebars')
Widget = require '../widget'

class Title extends Widget

    @template: handlebars.compile '<h1 data-field-type="title" data-placeholder="Title goes here..." data-fieldname-title="{{fieldTitle}}">{{title}}</h1>'



    constructor: (@fields = {}) ->
        @fields.title = 'title'
       
        
    render: (data) =>
        title = data.record[@fields.title]
        Title.template { title, fieldTitle: @fields.title }        

    
exports.Title = Title
