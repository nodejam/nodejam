mdparser = require('../lib/markdownutil').marked
ForaModel = require('./foramodel').ForaModel

class Image extends ForaModel
    @typeDefinition: {
        type: @,
        alias: 'Image',
        fields: {
            src: 'string',
            small: 'string !required',
            alt: 'string !required'
        }
    }
    

    
class TextContent extends ForaModel
    @typeDefinition: {
        type: @,
        alias: 'TextContent',
        fields: {
            text: { type: 'string', allowHtml: true },
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

exports.Image = Image
exports.TextContent = TextContent
