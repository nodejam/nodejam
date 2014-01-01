handlebars = require('handlebars')
Widget = require('./widget').Widget

class CardView extends Widget

    @template: handlebars.compile '
        <div class="card-face">
            {{{cardFace}}}
        </div>
        <div class="card-content">
            {{{content}}}
            <p class="content">Sometimes there is a sub-heading. It is often meaning-less. And does not stand the test of space.</p>
            <div class="content">
                <p class="sub-text">
                    <a href="/~{{post.createdBy.username}}">{{post.createdBy.name}}</a>
                    in <a href="/{{post.forum.stub}}">{{post.forum.name}}</a><br />
                    <i class="fa fa-comment"></i> 93 comments
                </p>
            </div>            
        </div>'



    constructor: (@params) ->
        
        
        
    render: (data) =>
        cardFace = content = ''
        
        for w in @params.cardFace
            cardFace += w.render data
        
        for w in @params.content
            content += w.render data
        
        CardView.template { cardFace, content, post: data.post }
    
        
exports.CardView = CardView
