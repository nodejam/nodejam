handlebars = require('handlebars')
Widget = require('./widget').Widget

class PostView extends Widget

    @template: handlebars.compile '
        <div class="item text">
            {{{postHtml}}}
        </div>
        <div class="sidebar large-page-element">
            {{{sidebarHtml}}}
            <div class="sidebar-options"></div>
        </div>'

    
    
    constructor: (params) ->
        @itemPane = params.itemPane
        @sidebar = params.sidebar

        
        
    render: (data) =>
        postHtml = sidebarHtml = ''
        for w in @itemPane
            postHtml += w.render data
        for w in @sidebar
            sidebarHtml += w.render data
        PostView.template { postHtml, sidebarHtml }
    
        
        
exports.PostView = PostView
