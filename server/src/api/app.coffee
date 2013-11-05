express = require 'express'
conf = require '../conf'
utils = require '../lib/utils'
expressutils = require '../lib/expressutils'
controllers = require './controllers'
validator = require 'validator'
ForaTypeUtils = require('../models/foratypeutils').ForaTypeUtils

host = conf.app.apiHost
port = conf.app.apiPort

utils.log "Fora API started at #{new Date} on #{host}:#{port}"

app = express()

getController = (name) ->
    switch name.toLowerCase()        
        when 'users' then new controllers.Users()
        when 'collections' then new controllers.Collections()
        when 'records' then new controllers.Records()
        when 'images' then new controllers.Images()
        else throw new Error "Cannot find controller #{name}."


expressutils.setup { app, getController, typeUtils: new ForaTypeUtils() }, (findHandler) ->
    app.post '/api/users', findHandler('users', (c) -> c.create)
    app.get '/api/users/:username', findHandler('users', (c) -> c.item)

    app.post '/api/collections', findHandler('collections', (c) -> c.create)
    app.post '/api/collections/:collection/members', findHandler('collections', (c) -> c.join)
    app.post '/api/collections/:collection', findHandler('records', (c) -> c.create)
    app.put '/api/collections/:collection/records/:record', findHandler('records', (c) -> c.edit)
    
    app.post '/api/images', findHandler('images', (c) -> c.upload)

    app.put "/api/admin/records/:id", findHandler('records', (c) -> c.admin_update)
    

app.listen port
