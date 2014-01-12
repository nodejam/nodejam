mdparser = require('../lib/markdownutil').marked
ForaModel = require('./foramodel').ForaModel

class Image extends ForaModel
    @typeDefinition: {
        type: @,
        name: 'image',
        fields: {
            src: 'string',
            small: 'string !required',
            alt: 'string !required',
            credits: 'string !required'
        }
    }
    


class Cover extends ForaModel
    @typeDefinition: {
        type: @,
        name: 'cover',
        fields: {
            image: 'image',
            bgColor: 'string !required',
            bgOpacity: 'number !required',
            foreColor: 'string !required',
        }
    }    
    

    
class TextContent extends ForaModel
    @typeDefinition: {
        type: @,
        name: 'text-content',
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
exports.Cover = Cover
exports.TextContent = TextContent
