handlebars = require('handlebars')
Widget = require('./widget').Widget

class Cover extends Widget

    @template: handlebars.compile '
    {{#if cover}}
    <div class="cover {{class}}"{{#if field}} data-field-type="cover" data-field-name="{{field}}" 
            data-cover-format="cover.type" data-small-image="{{cover.image.small}}"{{/if}}>

        <div class="image" style="background-image:url({{cover.image.src}})">
            <div class="underlay" style="{{#if cover.bgColor}}background:{{cover.bgColor}};{{/if}}{{#if cover.opacity}}opacity:{{cover.opacity}};{{/if}}"></div>
            <div class="content-wrap">
                {{#if content}}
                <div class="content" style="{{#if cover.foreColor}}color:{{cover.foreColor}};{{/if}}">
                {{{content}}}
                </div>
                {{/if}}
            </div>
        </div>

    </div>
    {{/if}}'
    
    
    @inlineTemplate: handlebars.compile '
    {{#if cover}}
    <div class="cover {{class}}"{{#if field}} data-field-type="cover" data-field-name="{{field}}" 
            data-cover-format="cover.type" data-small-image="{{cover.image.small}}"{{/if}}>

        <img src="{{cover.image.src}}" />

    </div>
    {{/if}}'
    



    constructor: (@params) ->
        
        
        
    render: (data, content) =>
        cover = @parseExpression @params.cover, data
        model = {}
        
        if cover
            model.cover = cover
            model.class = cover.type
            
            if @params.editable
                model.field = @params.field
                
            if content
                model.content = content
        
            if cover.type isnt 'inline-cover'
                Cover.template model
            else
                Cover.inlineTemplate model
        else
            ''
        
    
exports.Cover = Cover
