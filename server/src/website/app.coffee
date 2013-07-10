root = exports ? this

express = require 'express'
conf = require '../conf'
models = new (require '../models').Models(conf.db)
database = new (require '../common/database').Database(conf.db)
AppError = require('../common/apperror').AppError
utils = require '../common/utils'
ApplicationCache = require('../common/cache').ApplicationCache
validator = require('validator')
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
app.set('view options', { layout: 'layouts/default' })

#static file handlers.
#app.use('/', express.static(__dirname + '/public/root'))
app.use('/public', express.static(__dirname + '/public'))
app.use(express.favicon());

app.use express.cookieParser()

#check for cross site scripting
app.use (req,res,next) =>
    for inputs in [req.params, req.query, req.body]
        if inputs
            for key, val of inputs
                val = inputs[key]
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
            next new AppError 'Invalid Network', 'INVALID_NETWORK'
        

getNetwork = (hostName) ->    
    hostNames = hostName.split('.')
    if hostNames[0] is 'www'
        hostNames = hostNames[0].shift()
    hostName = hostNames.join('.')
    (n for n in conf.networks when n.domain is hostName)[0]
        
    

handleDomainUrls = (domain, fnHandler) ->
    (c) ->
        (req, res, next) ->
            req.params.domain = domain
            fnHandler(c)(req, res, next)  

# API Routes
# ----------
# AUTH
app.get '/auth/twitter', findHandler('ui/auth', (c) -> c.twitter)
app.get '/auth/twitter/callback', findHandler('ui/auth', (c) -> c.twitterCallback)
app.post '/api/sessions', findHandler('api/sessions', (c) -> c.create)

# FORUMS and POSTS
app.post '/api/forums', findHandler('api/forums', (c) -> c.create)
app.post '/api/forums/:forum', findHandler('api/forums', (c) -> c.createItem)

#ADMIN
app.put "/api/admin/posts/:id", findHandler('api/posts', (c) -> c.admin_update)

# UI Routes
# ---------
app.get '/', findHandler('ui/home', (c) -> c.index)
app.get '/:forum', findHandler('ui/forums', (c) -> c.index)

#Register templates, helpers etc.
require("./hbshelpers").register()

# ERROR HANDLING
app.use(app.router)

#handle errors
app.use (err, req, res, next) ->
    utils.log err
    res.send(500, { error: err })


# handle 404
app.use (req, res, next) ->
    res.status 404
    res.render('404', { url: req.url });
    res.send(404, { error: 'HTTP 404. There is no water here.' })

#Ensure indexes.
database.getDb (err, db) ->
    db.collection 'sessions', (_, coll) ->
        coll.ensureIndex { passkey: 1 }, ->
        coll.ensureIndex { accessToken: 1 }, ->

    db.collection 'users', (_, coll) ->
        coll.ensureIndex { 'username': 1, 'domain': 1 }, ->

    db.collection 'forums', (_, coll) ->
        coll.ensureIndex { 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1, 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'createdBy.domain': 1, 'network': 1 }, ->
        coll.ensureIndex { 'stub': 1, 'network': 1 }, ->

    db.collection 'posts', (_, coll) ->
        coll.ensureIndex { state: 1, 'network': 1 }, ->
        coll.ensureIndex { state: 1, publishedAt: 1, 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1, 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'createdBy.domain': 1, 'network': 1 }, ->
        
    db.collection 'messages', (_, coll) ->
        coll.ensureIndex { userid: 1 }, ->
        
    db.collection 'tokens', (_, coll) ->
        coll.ensureIndex { key: 1 }, ->

    
host = process.argv[2]
port = process.argv[3]
           
app.listen(port)
