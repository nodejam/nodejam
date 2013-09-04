root = exports ? this

path = require 'path'
express = require 'express'
validator = require 'validator'
conf = require '../conf'
utils = require '../common/utils'
db = new (require '../common/data/database').Database(conf.db)
uiControllers = require './controllers/ui'
apiControllers = require './controllers/api'

utils.log "Fora application started at #{new Date}"
utils.log "NODE_ENV is #{process.env.NODE_ENV}"

app = express()

app.use express.bodyParser({
    uploadDir:'../../www-user/temp',
    limit: '6mb'
})
app.use(express.limit('6mb'));

app.set("view engine", "hbs");
app.set('view options', { layout: conf.templates.layouts.default })

#static file handlers.
app.use express.favicon()
app.use express.cookieParser()

#check for cross site scripting
app.use (req,res,next) =>
    for inputs in [req.params, req.query, req.body]
        if inputs
            for key, val of inputs
                val = inputs[key]
                if typeof(val) is 'string'
                    if not /-html$/.test key
                        val = val.replace '<', '&lt;'
                        val = val.replace '>', '&gt;'                    
                    inputs[key] = validator.sanitize(val).xss()
    next()

findHandler = (name, getHandler) ->
    controller = switch name.toLowerCase()        
        when 'ui/auth' then new uiControllers.Auth()
        when 'ui/users' then new uiControllers.Users()
        when 'ui/home' then new uiControllers.Home()
        when 'ui/forums' then new uiControllers.Forums()
        when 'ui/dev_designs' then new uiControllers.Dev_Designs()
        when 'api/sessions' then new apiControllers.Sessions()
        when 'api/users' then new apiControllers.Users()
        when 'api/forums' then new apiControllers.Forums()
        when 'api/posts' then new apiControllers.Posts()
        when 'api/articles' then new apiControllers.Articles()
        when 'api/files/images' then new apiControllers.Images()
        else throw new Error "Cannot find controller #{name}."

    handler = getHandler(controller)
    
    (req, res, next) ->
        network = getNetwork req.headers.host
        if network
            req.network = network
            handler(req, res, next)
        else            
            next new Error 'Invalid Network'
        

getNetwork = (hostName) ->    
    matches = (n for n in conf.networks when n.domains.indexOf(hostName) isnt -1)
    if matches.length then matches[0]
        
    

handleDomainUrls = (domain, fnHandler) ->
    (c) ->
        (req, res, next) ->
            req.params.domain = domain
            fnHandler(c)(req, res, next)  

# API Routes
# ----------
app.post '/api/users', findHandler('api/users', (c) -> c.create)
app.get '/api/~:username', findHandler('api/users', (c) -> c.item)

# FORUMS and POSTS
app.post '/api/forums', findHandler('api/forums', (c) -> c.create)
app.post '/api/forums/:forum', findHandler('api/forums', (c) -> c.createItem)

#ADMIN
app.put "/api/admin/posts/:id", findHandler('api/posts', (c) -> c.admin_update)

# UI Routes
# ---------
app.get '/', findHandler('ui/home', (c) -> c.index)
app.get '/login', findHandler('ui/home', (c) -> c.login)

# AUTH
app.get '/auth/twitter', findHandler('ui/auth', (c) -> c.twitter)
app.get '/auth/twitter/callback', findHandler('ui/auth', (c) -> c.twitterCallback)

app.get '/forums', findHandler('ui/forums', (c) -> c.index)
app.get '/users/selectusername', findHandler('ui/users', (c) -> c.selectUsernameForm)
app.post '/users/selectusername', findHandler('ui/users', (c) -> c.selectUsername)
app.get '/~:username', findHandler('ui/users', (c) -> c.item)
app.get '/:forum', findHandler('ui/forums', (c) -> c.item)
app.get '/:forum/about', findHandler('ui/forums', (c) -> c.about)
app.get '/:forum/:stub', findHandler('ui/forums', (c) -> c.post)

#Register templates, helpers etc.
require("./hbshelpers").register()

# ERROR HANDLING
app.use(app.router)

#handle errors
app.use (err, req, res, next) ->
    utils.dumpError err
    res.send(500, { error: err })
    process.exit()


# handle 404
app.use (req, res, next) ->
    res.status 404
    res.render('404', { url: req.url });
    res.send(404, { error: 'HTTP 404. There is no water here.' })

#Ensure indexes.
db.getDb (err, db) ->
    db.collection 'sessions', (_, coll) ->
        coll.ensureIndex { passkey: 1 }, ->
        coll.ensureIndex { accessToken: 1 }, ->

    db.collection 'users', (_, coll) ->
        coll.ensureIndex { 'username': 1 }, ->

    db.collection 'forums', (_, coll) ->
        coll.ensureIndex { 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1, 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'network': 1 }, ->
        coll.ensureIndex { 'stub': 1, 'network': 1 }, ->

    db.collection 'posts', (_, coll) ->
        coll.ensureIndex { state: 1, 'forum.stub': 1 }, ->
        coll.ensureIndex { state: 1, 'forum.id': 1 }, ->
        coll.ensureIndex { state: 1, publishedAt: 1, 'forum.stub': 1 }, ->
        coll.ensureIndex { state: 1, publishedAt: 1, 'forum.id': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1 }, ->
        
    db.collection 'messages', (_, coll) ->
        coll.ensureIndex { userid: 1 }, ->
        
    db.collection 'tokens', (_, coll) ->
        coll.ensureIndex { key: 1 }, ->

    
host = conf.app.host
port = conf.app.port
           
app.listen(port)
