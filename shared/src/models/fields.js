(function() {
    "use strict";

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var markdown = require('markdown').markdown;
    var ForaModel = require('./foramodel').ForaModel;


    //Image
    var Image = function() {
        ForaModel.apply(this, arguments);
    };

    Image.prototype = Object.create(ForaModel.prototype);
    Image.prototype.constructor = Image;

    __extends(Image, ForaModel);

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


    //Cover
    var Cover = function() {
        ForaModel.apply(this, arguments);
    };

    Cover.prototype = Object.create(ForaModel.prototype);
    Cover.prototype.constructor = Cover;

    __extends(Cover, ForaModel);

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



    //TextContent
    var TextContent = function() {
        ForaModel.apply(this, arguments);
    };

    TextContent.prototype = Object.create(ForaModel.prototype);
    TextContent.prototype.constructor = TextContent;

    __extends(Cover, ForaModel);

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
