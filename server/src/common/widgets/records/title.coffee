handlebars = require('handlebars')
Widget = require '../widget'

class Title extends Widget

    @template: handlebars.compile '<h1 data-editor-type="title" data-placeholder="Title goes here...">{{title}}</h1>'



    constructor: (@title = 'title') ->

       
        
    render: (data) =>
        title = data.record[@title]
        Title.template { title }        

    
exports.Title = Title
