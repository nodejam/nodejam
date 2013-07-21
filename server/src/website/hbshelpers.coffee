#Handlebars helpers
exports.register = ->
    hbs = require('hbs')

    hbs.registerHelper 'userUrl', (user) -> if user.domain is 'twitter' then "/@#{user.username}" else "/#{user.domain}/#{user.username}"
    hbs.registerHelper 'userFeedUrl', (user) -> if user.domain is 'twitter' then "/@#{user.username}/feed" else "/#{user.domain}/#{user.username}/feed"

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
    fs = require('fs')
    conf = require('../conf')    
    postcard = fs.readFileSync(__dirname + conf.defaultViews.posts.postcard, 'utf8');
    hbs.registerPartial('postcard', postcard); 
    forumcard = fs.readFileSync(__dirname + conf.defaultViews.forums.forumcard, 'utf8');
    hbs.registerPartial('forumcard', forumcard); 

