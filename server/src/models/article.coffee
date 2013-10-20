Record = require('./record').Record
utils = require('../lib/utils')
Q = require('../lib/q')
models = require('./')
widgets = require '../common/widgets/records'

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
            cover: { type: Record.Fields.Cover, required: false },
            content: { type: Record.Fields.TextContent }
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
                    params: {
                        itemPane: [
                            { widget: 'cover' },
                            { widget: 'title' },
                            { widget: 'authorship', params: { type: 'small' } },
                            { widget: 'text' },
                        ],
                        sidebar: [ { widget: 'authorship' } ]
                    }
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
            when "card"
                {
                    image: @cover?.small,
                    @title,
                    content: @content.formatContent(),
                    @createdBy,
                    @collection,
                    id: @_id.toString(),
                    @stub
                }

exports.Article = Article

