Record = require('./record').Record
utils = require('../lib/utils')
Q = require('../lib/q')
models = require('./')
widgets = require '../common/widgets'
fields = require './fields'

class Article extends Record

    @describeType: {
        type: @,
        alias: 'article',
        inherits: Record,
        description: 'Article',
        fields: {
            title: { type: 'string', required: false, maxLength: 200 }
            subtitle: { type: 'string', required: false, maxLength: 200 },
            synopsis: { type: 'string', required: false, maxLength: 2000 },
            cover: 'Image !required',
            content: 'TextContent'
        },
        stub: 'title'
    }



    constructor: (params) ->
        super
        @type ?= 'article'

        

    getTemplate: (name = "standard") =>
        switch name
            when 'standard'
                @parseTemplate {
                    widget: "recordview",
                    itemPane: [
                        { widget: 'image', image: '@cover', editable: true, class: 'cover' },
                        { widget: 'title' },
                        { widget: 'authorship', type: 'small' },
                        { widget: 'text', text: '@content' },
                    ],
                    sidebar: [ { widget: 'authorship' } ]
                }
            when 'card'
                @parseTemplate {
                    widget: "cardview",
                    cover: [{ widget: "image", image: '@cover', type: 'small', bg: true }],
                    content: [
                        { widget: "title", link: 'hbs /{{collection.stub}}/{{stub}}' },
                        { widget: 'text', text: '@content' }
                    ]
                }
                
                            

    getView: (name = "standard") =>
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

