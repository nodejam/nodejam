#Handlebars helpers
exports.register = ->
    hbs = require('hbs')

    hbs.registerHelper 'equals', (v1, v2, options) ->
        if v1 is v2
            options.fn(this)
        else        
            options.inverse(this)

    hbs.registerHelper 'formatComment', (comment, type) ->
        if type is 'text'
            content = comment.data
            #replace more than three newlines with a double newline
            content = content.replace(/[\n]{3,}/g, "\n\n")
            content = content.replace /\n/g, "<br />"
            "<div class=\"author\"><img src=\"#{comment.createdBy.thumbnail}\" alt=\"#{comment.createdBy.name}\" /> <span class=\"name\">#{comment.createdBy.name}</span></div>
            <div class=\"content\">#{content}</div>"    
        else
            "Unsupported comment type."

    #Templates
    fs = require 'fs'
    path = require 'path'
    conf = require '../conf'
    recordcard = fs.readFileSync path.join(__dirname, conf.templates.views.records.recordcard), 'utf8'
    hbs.registerPartial 'recordcard', recordcard
    collectioncard = fs.readFileSync path.join(__dirname, conf.templates.views.collections.collectioncard), 'utf8'
    hbs.registerPartial 'collectioncard', collectioncard

