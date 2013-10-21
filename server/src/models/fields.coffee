mdparser = require('../lib/markdownutil').marked
ForaModel = require('./foramodel').ForaModel

class CoverPicture extends ForaModel
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
        "CoverPicture1"
    
    
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
        "TextContent"
        
exports.CoverPicture = CoverPicture
exports.TextContent = TextContent
