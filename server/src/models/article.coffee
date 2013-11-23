Post = require('./post').Post
utils = require('../lib/utils')
Q = require '../lib/q'
models = require('./')
widgets = require '../common/widgets'
fields = require './fields'

class Article extends Post

    @typeDefinition: {
        type: @,
        alias: 'Article',
        inherits: 'Post',
        fields: {
            title: { type: 'string', required: false, maxLength: 200 }
            subtitle: { type: 'string', required: false, maxLength: 200 },
            synopsis: { type: 'string', required: false, maxLength: 2000 },
            cover: 'Image !required',
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
                        { widget: 'image', image: '@post.cover', editable: true, field: 'cover',  size: 1 },
                        { widget: 'heading', title: '@post.title', size: 1, editable: true, field: 'title' },
                        { widget: 'authorship', type: 'small', author: '@author' },
                        { widget: 'text', text: '@post.content', editable: true, field: 'content' },
                    ],
                    sidebar: [ { widget: 'authorship', author: '@author' } ]
                }
            when 'card'
                @parseTemplate {
                    widget: "cardview",
                    content: [
                        { widget: "heading", size: 2, title: '@post.title', link: 'hbs /{{forum.stub}}/{{post.stub}}' },
                        { widget: "image", image: '@post.cover', type: 'small', bg: true },
                        { widget: 'text', text: '@post.content' }
                    ]
                }
                
                            

    getView: (name) =>
        switch name
            when "snapshot"
                {
                    image: @cover?.small,
                    @title,
                    @createdBy,
                    id: @_id.toString(),
                    @stub
                } 

exports.Article = Article

