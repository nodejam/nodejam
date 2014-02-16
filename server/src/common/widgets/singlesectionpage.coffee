handlebars = require('handlebars')
widgets = require('./')
Widget = require('./widget').Widget

class SingleSectionPage extends Widget

    @template: handlebars.compile '        
        <div class="single-section-page single-column">
            {{{cover}}}
            <div class="main-pane">
                <div class="content-area upsize item">
                {{{html}}}
                </div>
            </div>
        </div>'

    
    constructor: (@params) ->
        
        
        
    render: (data) =>
        result = {}

        cover = ''
        if @params.cover
            if @params.cover.type is 'full-cover'
                cover = @params.cover.render data, (@params.title.render(data) + @params.author.render(data))
                contents = @params.contents                
            else
                cover = @params.cover.render data
                contents = [@params.title, @params.author].concat(@params.contents)
        else
            contents = [@params.title, @params.author].concat(@params.contents)
        
        html = ''        
        for item in contents
            html += item.render data
        
        SingleSectionPage.template { cover, html }
    
        
        
exports.SingleSectionPage = SingleSectionPage
