handlebars = require('handlebars')
Widget = require('./widget').Widget

class MultiSectionPage extends Widget

    @template: handlebars.compile '
        <div class="main-pane">
            {{html}}
        </div>'

    
    constructor: (params) ->
        @cover = params.cover
        @heading = params.heading
        @subHeading = params.subHeading
        @contents = params.contents
        
        
        
    render: (data) =>
        result = {}

        if @cover.cover
            result.pageType += " auto-cover"
            result.cover = ""
            result.coverContent = @heading.render(data) + @subHeading?.render(data)
            contentWidgets = @contents
        else
            result.pageType += " sans-cover"
            contentWidgets = [@heading, @subHeading].concat @contents
            
        html = ''
        for item in contentWidgets
            html += item.render data
        
        result.html = SingleSectionPage.template { html }
            
        result
    
        
        
exports.MultiSectionPage = MultiSectionPage
