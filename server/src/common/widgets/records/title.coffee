handlebars = require('handlebars')
Widget = require '../widget'

class Title extends Widget

    @template: handlebars.compile '<h1 data-field-type="title" data-field-title=>{{fieldTitle}}</h1>'



    constructor: (@title = 'title') ->

       
        
    render: (data) =>
        title = data.record[@title]
        Title.template { title, fieldTitle: @title }        

    
exports.Title = Title
