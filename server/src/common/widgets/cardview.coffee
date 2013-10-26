handlebars = require('handlebars')
Widget = require('./widget').Widget

class CardView extends Widget

    constructor: (params) ->
        @items = params.items
        
        
    render: (data) =>
        html = ''
        for w in @items
            html += w.render data.record
        html
    
        
exports.CardView = CardView


