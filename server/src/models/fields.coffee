ForaModel = require('./foramodel').ForaModel

class Cover extends ForaModel
    @describeType: {
        type: @,
        alias: '',
        fields: {
            image: 'string',
            small: 'string',
            alt: 'string !required'
        }
    }
    
    @toJSON: ->
        "Fields.Cover"
    
    
class TextContent extends ForaModel
    @describeType: {
        type: @,
        fields: {
            text: 'string',
            format: 'string'
        }
    }

    formatContent: =>
        switch @format
            when 'markdown'
                if @text then mdparser(@text) else ''
            when 'html', 'text'
                @text
            else
                'Invalid format.'

    @toJSON: ->
        "Fields.TextContent"
        
exports.Cover = Cover
exports.TextContent = TextContent
