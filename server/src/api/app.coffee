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
        when 'collections' then new controllers.Collections()
        when 'records' then new controllers.Records()
        when 'images' then new controllers.Images()
        else throw new Error "Cannot find controller #{name}."

http404 = (req, res, next) ->
    res.send 404

expressutils.setup { app, getController, typeUtils: new ForaTypeUtils(), http404 }, (findHandler) ->
    app.get '/api/healthcheck', (req, res, next) -> res.send { jacksparrow: "alive" }

    app.post '/api/users', findHandler('users', (c) -> c.create)
    app.get '/api/users/:username', findHandler('users', (c) -> c.item)

    app.post '/api/collections', findHandler('collections', (c) -> c.create)
    app.post '/api/collections/:collection/members', findHandler('collections', (c) -> c.join)
    app.post '/api/collections/:collection', findHandler('records', (c) -> c.create)
    app.put '/api/collections/:collection/records/:record', findHandler('records', (c) -> c.edit)
    
    app.post '/api/images', findHandler('images', (c) -> c.upload)

    app.put "/api/admin/records/:id", findHandler('records', (c) -> c.admin_update)
    
app.listen port
