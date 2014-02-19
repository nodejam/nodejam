mdparser = require('../lib/markdownutil').marked
ForaModel = require('./foramodel').ForaModel

class Image extends ForaModel
    @typeDefinition: {
        name: 'image',
        schema: {
            type: 'object',        
            properties: {
                src: { type: 'string' },
                small: { type: 'string' },
                alt: { type: 'string' },
                credits: { type: 'string' },
            },
            required: ['src']
        },
    }
    


class Cover extends ForaModel
    @typeDefinition: {
        name: 'cover',
        schema: {
            type: 'object',        
            properties: {
                type: { type: 'string' },
                image: { $ref: 'image' },
                bgColor: { type: 'string' },
                bgOpacity: { type: 'string' },
                foreColor: { type: 'string' },
            },
            required: ['image']
        },
    }    
    

    
class TextContent extends ForaModel

    @typeDefinition: {
        name: 'text-content',
        schema: {
            type: 'object',        
            properties: {
                text: { type: 'string' },
                format: { type: 'string' }
            },
            required: ['text', 'format']            
        },        
        allowHtml: ['text']
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
