handlebars = require('handlebars')
Widget = require('./widget').Widget

class Authorship extends Widget
    
    # For large screens
    @template = handlebars.compile '
        <div class="header stamp-block">
            <img src="{{assetUrl}}/{{author.username}}.jpg" alt="{{author.name}}" />
            <h2>{{author.name}}</h2>
            <p>
                {{author.about}}
            </p>
            <p>
                <span class="light-text">Yesterday in <a href="/{{forum.stub}}">{{forum.name}}</a></span>
            </p>     
        </div>'
        
    
    # For tiny and small screens
    @smallTemplate = handlebars.compile '
        <div class="small-page-element tiny-page-element">
            <div class="icon-block sub-heading">            
                <img src="{{assetUrl}}/{{author.username}}_t.jpg" alt="{{author.name}}" />
                <span class="text">
                    <a href="/~{{author.username}}">{{author.name}}</a><br />
                    <span class="light-text">Yesterday in <a href="/{{forum.stub}}">{{forum.name}}</a></span>
                </span>
            </div>
        </div>'
        
        

    constructor: (@params) ->
        @params.author = '@author'
        @params.forum = '@forum'
        
        
        
    render: (data) =>
        author = @parseExpression @params.author, data
        forum = @parseExpression @params.forum, data
        assetUrl = author.getAssetUrl()
        
        (if @params.type is 'small' then Authorship.smallTemplate else Authorship.template) { author, forum, assetUrl }

    
exports.Authorship = Authorship


