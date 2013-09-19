express = require 'express'
conf = require '../conf'
utils = require '../common/utils'
webutils = require '../common/webutils'
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
        when 'forums' then new controllers.Forums()
        when 'posts' then new controllers.Posts()
        else throw new Error "Cannot find controller #{name}."
        

webutils.setup app, getController, (findHandler) ->
    # Routes
    app.get '/', findHandler('home', (c) -> c.index)
    app.get '/login', findHandler('home', (c) -> c.login)

    app.get '/auth/twitter', findHandler('auth', (c) -> c.twitter)
    app.get '/auth/twitter/callback', findHandler('auth', (c) -> c.twitterCallback)

    app.get '/forums', findHandler('forums', (c) -> c.index)
    app.get '/users/selectusername', findHandler('users', (c) -> c.selectUsernameForm)
    app.post '/users/selectusername', findHandler('users', (c) -> c.selectUsername)
    app.get '/~:username', findHandler('users', (c) -> c.item)
    app.get '/:forum', findHandler('forums', (c) -> c.item)
    app.get '/:forum/new', findHandler('forums', (c) -> c.createForm)
    app.get '/:forum/about', findHandler('forums', (c) -> c.about)
    app.get '/:forum/:stub', findHandler('posts', (c) -> c.item)
    
#Register templates, helpers etc.
require("./hbshelpers").register()

app.listen port
