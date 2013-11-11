#Handlebars helpers
exports.register = ->
    hbs = require('hbs')

    hbs.registerHelper 'equals', (v1, v2, options) ->
        if v1 is v2
            options.fn(this)
        else        
            options.inverse(this)

    #Templates
    fs = require 'fs'
    path = require 'path'
    conf = require '../conf'
    forumcard = fs.readFileSync path.join(__dirname, conf.templates.views.forums.forumcard), 'utf8'
    hbs.registerPartial 'forumcard', forumcard

