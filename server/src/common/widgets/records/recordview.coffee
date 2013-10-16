handlebars = require('handlebars')
Widget = require '../widget'

class RecordView extends Widget

    @template: handlebars.compile '
        <div class="item text">
            {{{recordHtml}}}
        </div>
        <div class="sidebar large-page-element">
            {{{sidebarHtml}}}
        </div>'

    
    
    constructor: (@itemPane, @sidebar) ->

        
        
    render: (data) =>
        recordHtml = sidebarHtml = ''
        for w in @itemPane
            recordHtml += w.render data
        for w in @sidebar
            sidebarHtml += w.render data
        RecordView.template { recordHtml, sidebarHtml }
    
        
        
exports.RecordView = RecordView
