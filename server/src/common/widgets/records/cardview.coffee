handlebars = require('handlebars')
Widget = require '../widget'

class CardView extends Widget

    @template: handlebars.compile '
        <li class="{{view}}" data-url="/{{collection.stub}}/{{stub}}">
            <div class="item-wrap">
                {{#if image}} 
                <div class="image" style="background-image:url({{image}})"></div>
                {{/if}}
                <div class="content-wrap">
                    <div class="content">
                        <h2><a href="/{{collection.stub}}/{{stub}}">{{title}}</a></h2>
                        {{{content}}}
                    </div>
                    <div class="overlay"></div>
                    <span class="activity">
                        <i class="icon-comment"></i> 93<br />
                        <i class="icon-thumbs-up-alt"></i> 10k
                    </span>
                    <p class="desc-text">
                        <span class="text">
                            <a href="/~{{createdBy.username}}">{{createdBy.name}}</a><br />
                            <span class="light-text">in <a href="/{{collection.stub}}">{{collection.name}}</a></span>
                        </span>
                    </p>
                </div>
            </div>
        </li>'

    
    
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


