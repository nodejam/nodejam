handlebars = require('handlebars')
Widget = require('./widget').Widget

class RecordView extends Widget

    @template: handlebars.compile '
        <div class="item text">
            {{{recordHtml}}}
        </div>
        <div class="sidebar large-page-element">
            {{{sidebarHtml}}}
            <div class="sidebar-options"></div>
        </div>'

    
    
    constructor: (params) ->
        @itemPane = params.itemPane
        @sidebar = params.sidebar

        
        
    render: (data) =>
        recordHtml = sidebarHtml = ''
        for w in @itemPane
            recordHtml += w.render data
        for w in @sidebar
            sidebarHtml += w.render data
        RecordView.template { recordHtml, sidebarHtml }
    
        
        
exports.RecordView = RecordView
