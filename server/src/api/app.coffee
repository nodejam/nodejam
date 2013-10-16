express = require 'express'
conf = require '../conf'
utils = require '../lib/utils'
expressutils = require '../lib/expressutils'
controllers = require './controllers'
validator = require 'validator'

host = conf.app.apiHost
port = conf.app.apiPort

utils.log "Fora API started at #{new Date} on #{host}:#{port}"

app = express()

getController = (name) ->
    switch name.toLowerCase()        
        when 'auth' then new controllers.Auth()
        when 'users' then new controllers.Users()
        when 'home' then new controllers.Home()
        when 'collections' then new controllers.Collections()
        when 'records' then new controllers.Records()
        else throw new Error "Cannot find controller #{name}."


expressutils.setup app, getController, (findHandler) ->
    app.post '/api/users', findHandler('users', (c) -> c.create)
    app.get '/api/users/:username', findHandler('users', (c) -> c.item)

    app.post '/api/collections', findHandler('collections', (c) -> c.create)
    app.post '/api/collections/:collection/members', findHandler('collections', (c) -> c.join)
    app.post '/api/collections/:collection', findHandler('records', (c) -> c.create)

    app.put "/api/admin/records/:id", findHandler('records', (c) -> c.admin_update)
    

app.listen port
