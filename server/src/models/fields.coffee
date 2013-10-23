mdparser = require('../lib/markdownutil').marked
ForaModel = require('./foramodel').ForaModel

class Image extends ForaModel
    @describeType: {
        type: @,
        alias: '',
        fields: {
            src: 'string',
            small: 'string !required',
            alt: 'string !required'
        }
    }
    
    @toJSON: ->
        "Image"
    
    
    
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
        
exports.Image = Image
exports.TextContent = TextContent
