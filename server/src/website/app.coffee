express = require 'express'
conf = require '../conf'
utils = require '../lib/utils'
expressutils = require '../lib/expressutils'
controllers = require './controllers'

host = conf.app.websiteHost
port = conf.app.websitePort

utils.log "Fora Website started at #{new Date} on #{host}:#{port}"

app = express()

app.set("view engine", "hbs");
app.set('view options', { layout: conf.templates.layouts.default })

app.use express.favicon()
app.use express.cookieParser()

getController = (name) ->
    switch name.toLowerCase()        
        when 'auth' then new controllers.Auth()
        when 'users' then new controllers.Users()
        when 'home' then new controllers.Home()
        when 'collections' then new controllers.Collections()
        when 'records' then new controllers.Records()
        else throw new Error "Cannot find controller #{name}."
        

expressutils.setup app, getController, (findHandler) ->
    # Routes
    app.get '/', findHandler('home', (c) -> c.index)
    app.get '/login', findHandler('home', (c) -> c.login)

    app.get '/auth/twitter', findHandler('auth', (c) -> c.twitter)
    app.get '/auth/twitter/callback', findHandler('auth', (c) -> c.twitterCallback)

    app.get '/collections', findHandler('collections', (c) -> c.index)
    app.get '/users/selectusername', findHandler('users', (c) -> c.selectUsernameForm)
    app.post '/users/selectusername', findHandler('users', (c) -> c.selectUsername)
    app.get '/~:username', findHandler('users', (c) -> c.item)
    app.get '/:collection', findHandler('collections', (c) -> c.item)
    app.get '/:collection/new', findHandler('collections', (c) -> c.createForm)
    app.get '/:collection/about', findHandler('collections', (c) -> c.about)
    app.get '/:collection/:stub', findHandler('records', (c) -> c.item)
    
#Register templates, helpers etc.
require("./hbshelpers").register()

app.listen port
