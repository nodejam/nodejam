express = require 'express'
conf = require '../conf'
utils = require '../common/utils'
webutils = require '../common/webutils'
controllers = require './controllers'

host = conf.app.apiHost
port = conf.app.apiPort

utils.log "Fora API started at #{new Date} on #{host}:#{port}"

app = express()

getController = (name) ->
    switch name.toLowerCase()        
        when 'auth' then new controllers.Auth()
        when 'users' then new controllers.Users()
        when 'home' then new controllers.Home()
        when 'forums' then new controllers.Forums()
        when 'posts' then new controllers.Posts()
        else throw new Error "Cannot find controller #{name}."

webutils.setup app, getController, (findHandler) ->
    # Routes
    app.post '/api/users', findHandler('users', (c) -> c.create)
    app.get '/api/users/:username', findHandler('users', (c) -> c.item)

    # FORUMS and POSTS
    app.post '/api/forums', findHandler('forums', (c) -> c.create)
    app.post '/api/forums/:forum/members', findHandler('forums', (c) -> c.join)
    app.post '/api/forums/:forum', findHandler('posts', (c) -> c.create)

    #ADMIN
    app.put "/api/admin/posts/:id", findHandler('posts', (c) -> c.admin_update)
    

app.listen port
