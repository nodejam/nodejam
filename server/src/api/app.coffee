express = require 'express'
utils = require '../lib/utils'
expressutils = require '../lib/expressutils'
controllers = require './controllers'
validator = require 'validator'
ForaTypeUtils = require('../models/foratypeutils').ForaTypeUtils

process.chdir __dirname

host = process.argv[2]
port = process.argv[3]

if not host or not port
    utils.log "Usage: app.js host port"
    process.exit()

utils.log "Fora API started at #{new Date} on #{host}:#{port}"

app = express()

getController = (name) ->
    switch name.toLowerCase()        
        when 'users' then new controllers.Users()
        when 'forums' then new controllers.Forums()
        when 'posts' then new controllers.Posts()
        when 'images' then new controllers.Images()
        else throw new Error "Cannot find controller #{name}."

expressutils.setup { app, getController, typeUtils: new ForaTypeUtils() }, (findHandler) ->
    app.get '/api/healthcheck', (req, res, next) -> res.send { jacksparrow: "alive" }

    app.post '/api/users', findHandler('users', (c) -> c.create)
    app.get '/api/users/:username', findHandler('users', (c) -> c.item)

    app.post '/api/forums', findHandler('forums', (c) -> c.create)
    app.post '/api/forums/:forum/members', findHandler('forums', (c) -> c.join)
    app.post '/api/forums/:forum', findHandler('posts', (c) -> c.create)
    app.put '/api/forums/:forum/posts/:id', findHandler('posts', (c) -> c.edit)
    
    app.post '/api/images', findHandler('images', (c) -> c.upload)

    app.put "/api/admin/posts/:id", findHandler('posts', (c) -> c.admin_update)
    
app.listen port
