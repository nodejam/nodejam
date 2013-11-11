Record = require('./record').Record
utils = require('../lib/utils')
Q = require('../lib/q')
models = require('./')
widgets = require '../common/widgets'
fields = require './fields'

class Article extends Record

    @typeDefinition: {
        type: @,
        alias: 'Article',
        inherits: 'Record',
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
                    widget: "recordview",                    
                    itemPane: [
                        { widget: 'image', image: '@record.cover', editable: true, field: 'cover',  size: 1 },
                        { widget: 'heading', title: '@record.title', size: 1, editable: true, field: 'title' },
                        { widget: 'authorship', type: 'small', author: '@author' },
                        { widget: 'text', text: '@record.content', editable: true, field: 'content' },
                    ],
                    sidebar: [ { widget: 'authorship', author: '@author' } ]
                }
            when 'card'
                @parseTemplate {
                    widget: "cardview",
                    cover: [{ widget: "image", image: '@record.cover', type: 'small', bg: true }],
                    content: [
                        { widget: "heading", size: 2, title: '@record.title', link: 'hbs /{{forum.stub}}/{{record.stub}}' },
                        { widget: 'text', text: '@record.content' }
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

