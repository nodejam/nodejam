handlebars = require('handlebars')
Widget = require('./widget').Widget

class CardView extends Widget

    @template: handlebars.compile '
        {{{cover}}}
        <div class="content-wrap">
            {{{content}}}
            <div class="overlay"></div>
            <span class="activity">
                <i class="fa fa-comment"></i> 93<br />
                <i class="fa fa-thumbs-up"></i> 10k
            </span>
            <p class="desc-text">
                <span class="text">
                    <a href="/~{{record.createdBy.username}}">{{record.createdBy.name}}</a><br />
                    <span class="light-text">in <a href="/{{record.collection.stub}}">{{record.collection.name}}</a></span>
                </span>
            </p>
        </div>'



    constructor: (@params) ->
        
        
        
    render: (data) =>
        cover = content = ''
        
        for w in @params.cover
            cover += w.render data
        for w in @params.content
            content += w.render data
        
        CardView.template { cover, content, record: data.record }
    
        
exports.CardView = CardView
