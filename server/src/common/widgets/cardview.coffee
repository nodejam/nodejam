handlebars = require('handlebars')
Widget = require('./widget').Widget

class CardView extends Widget

    @template: handlebars.compile '
        <div class="content-wrap">
            {{{content}}}
        </div>
        <div class="card-info">
            <div class="overlay"></div>
            <span class="activity">
                <i class="fa fa-comment"></i> 93<br />
                <i class="fa fa-thumbs-up"></i> 10k
            </span>
            <p class="desc-text">
                <a href="/~{{record.createdBy.username}}">{{record.createdBy.name}}</a><br />
                <span class="italicize">in <a href="/{{record.forum.stub}}">{{record.forum.name}}</a></span>
            </p>
        </div>'



    constructor: (@params) ->
        
        
        
    render: (data) =>
        content = ''
        
        for w in @params.content
            content += w.render data
        
        CardView.template { content, record: data.record }
    
        
exports.CardView = CardView
