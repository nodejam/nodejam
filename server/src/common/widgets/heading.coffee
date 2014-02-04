handlebars = require('handlebars')
Widget = require('./widget').Widget

class Heading extends Widget

    @header: handlebars.compile '
        <div class="cover"{{#if field}} data-field-type="cover" data-field-name="{{field}}" 
        data-cover-format="{{cover.type}}" data-small-image="{{cover.image.small}}"{{/if}}>

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

        </div>'


    @headerWithLink: handlebars.compile '<{{element}} {{{attr}}}"><a href="{{link}}">{{title}}</a></{{element}}>'


    constructor: (@params) ->
        
        
    render: (data) =>
        title = @parseExpression @params.title, data
        link = @parseExpression @params.link, data
        
        element = "h" + parseInt(@params.size)
        
        attribs = {}
        
        if @params.class
            attribs.class = @params.class

        if @params.field
            attribs['data-field-type'] = 'heading'
            attribs['data-field-name'] = @params.field
            attribs['data-placeholder'] = "Title goes here..."   

        attr = @toAttributes(attribs)                 
        
        if not link
            Heading.header { title, element, attr }
        else
            Heading.headerWithLink { title, link, element, attr }
            
    
exports.Heading = Heading
