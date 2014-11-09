(function() {
    "use strict";

    var markdown = require('markdown').markdown,
        dataUtils = require('fora-data-utils');

    var Image = function(params) {
        dataUtils.extend(this, params);
    };

    Image.typeDefinition = {
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
    };


    var Cover = function(params) {
        dataUtils.extend(this, params);
    };

    Cover.typeDefinition = {
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
    };


    var TextContent = function() {};

    TextContent.typeDefinition = {
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
    };


    TextContent.prototype.formatContent = function() {
        switch (this.format) {
            case "markdown":
                return this.text ? markdown.toHTML(this.text) : '';
            case 'html':
            case 'text':
                return this.text;
            default:
                return "Invalid format";
        }
    };


    module.exports = {
        Image: Image,
        Cover: Cover,
        TextContent: TextContent
    };

})();
