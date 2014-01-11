models = require('../')
Post = require('../post').Post
fields = require '../fields'
widgets = require '../../common/widgets'

class Article extends Post

    @typeDefinition: {
        type: @,
        alias: 'Article',
        inherits: 'Post',
        fields: {
            title: { type: 'string', required: false, maxLength: 200 }
            subtitle: { type: 'string', required: false, maxLength: 200 },
            synopsis: { type: 'string', required: false, maxLength: 2000 },
            cover: 'Cover !required',
            content: 'TextContent !required'
        }
    }



    constructor: (params) ->
        super
        @type ?= 'Article'
        @content ?= new fields.TextContent { text: '', format: 'html' }
        
        

    getTemplate: (name = "standard") =>
        switch name
            when 'standard'
                @parseTemplate {
                    widget: "postview",                    
                    itemPane: [
                        { widget: 'cover', cover: '@post.cover', field: 'cover',  editable: true, size: 1 },
                        { widget: 'heading', title: '@post.title', field: 'title', editable: true, size: 1 },
                        { widget: 'authorship', type: 'small', author: '@author' },
                        { widget: 'text', text: '@post.content', field: 'content', editable: true },
                    ],
                    sidebar: [ { widget: 'authorship', author: '@author' } ]
                }
            when 'card'
                cardFace = []
                
                if @cover
                    cardFace.push { widget: "image", image: '@post.cover.image', type: 'small', bg: true }
                else
                    cardFace.push { 
                        widget: "html", 
                        html: "<div class=\"content-wrap\">Hello World</div>"
                    }
                    
                @parseTemplate {
                    widget: "cardview",
                    cardFace,
                    content: [
                        { widget: "heading", size: 2, title: '@post.title', link: 'hbs /{{forum.stub}}/{{post.stub}}' },
                    ]
                }

                            

    getView: (name) =>
        switch name
            when "snapshot"
                {
                    image: @cover?.image.small,
                    @title,
                    @createdBy,
                    id: @_id.toString(),
                    @stub
                } 

exports.Article = Article

