recordModule = require('./record')
utils = require('../lib/utils')
Q = require('../lib/q')
models = require('./')
widgets = require '../common/widgets/records'

class Article extends recordModule.Record

    @describeType: {
        type: @,
        inherits: recordModule.Record,
        name: 'article',
        description: 'Article',
        fields: {
            title: { type: 'string', required: false, maxLength: 200 }
            subtitle: { type: 'string', required: false, maxLength: 200 },
            synopsis: { type: 'string', required: false, maxLength: 2000 },
            cover: { type: 'string', required: false, maxLength: 200 },
            coverAlt: { type: 'string', required: false, maxLength: 200 },
            smallCover: { type: 'string', required: false, maxLength: 200, validate: -> if @cover and not @smallCover then 'Missing small cover.' else true },
            content: { type: 'string', format: 'format', required: false, maxLength: 100000 },
            format: { type: 'string', $in: ['markdown'], map: { default: 'markdown' } },
        },
        stub: 'title'
    }



    constructor: (params) ->
        super
        @type ?= 'article'



    getTemplate: (name = "standard") =>
        switch name
            when 'standard'
                itemPane = [
                    new widgets.Cover,
                    new widgets.Title,
                    new widgets.Authorship('small'),
                    new widgets.Text
                ]
                sidebar = [ new widgets.Authorship ]
                new widgets.RecordView itemPane, sidebar
            


    getView: (name = "standard") =>
        switch name
            when "snapshot"
                {
                    image: @smallCover,
                    @title,
                    @createdBy,
                    id: @_id.toString(),
                    @stub
                } 
            when "card"
                {
                    image: @smallCover,
                    @title,
                    content: @formatData(@content, @format),
                    @createdBy,
                    @collection,
                    id: @_id.toString(),
                    @stub
                }



exports.Article = Article

