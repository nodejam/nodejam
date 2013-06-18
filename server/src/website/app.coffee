root = exports ? this

console.log "Fora application started at #{new Date}"
console.log "NODE_ENV is #{process.env.NODE_ENV}"

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
        when 'ui/networks' then new uiControllers.Networks()            
        when 'ui/home' then new uiControllers.Home()
        when 'ui/forums' then new uiControllers.Forums()
        when 'ui/dev_designs' then new uiControllers.Dev_Designs()
        when 'api/sessions' then new apiControllers.Sessions()
        when 'api/users' then new apiControllers.Users()
        when 'api/networks' then new apiControllers.Networks()
        when 'api/forums' then new apiControllers.Forums()
        when 'api/files/images' then new apiControllers.Images()
        when 'api/admin' then new apiControllers.Admin()            
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

#AUTH
app.get '/auth/twitter', findHandler('ui/auth', (c) -> c.twitter)
app.get '/auth/twitter/callback', findHandler('ui/auth', (c) -> c.twitterCallback)
app.post '/api/:version/sessions', findHandler('api/sessions', (c) -> c.create)

#HOME
app.get '/', findHandler('ui/home', (c) -> c.index)
app.get '/:forum', findHandler('ui/forums', (c) -> c.index)
app.post '/api/:version/forums', findHandler('ui/forums', (c) -> c.create)

#TESTING DESIGNS
app.get '/app/dev/designs/cover', findHandler('ui/dev_designs', (c) -> c.cover)

#ERROR HANDLING
app.use(app.router)

#handle errors
###
app.use (err, req, res, next) ->
    console.log err
    res.send(500, { error: err })
###


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

    db.collection 'forums', (_, coll) ->
        coll.ensureIndex { 'createdBy.id': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'createdBy.domain': 1 }, ->
        coll.ensureIndex { 'stub': 1 }, ->

    db.collection 'posts', (_, coll) ->
        coll.ensureIndex { uid: 1 }, ->
        coll.ensureIndex { uid: 1, state: 1 }, ->
        coll.ensureIndex { uid: -1, state: 1 }, ->
        coll.ensureIndex { publishedAt: 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'createdBy.domain': 1 }, ->
        
    db.collection 'messages', (_, coll) ->
        coll.ensureIndex { userid: 1 }, ->
        coll.ensureIndex { 'related.type': 1, 'related.id' }, ->
        
    db.collection 'tokens', (_, coll) ->
        coll.ensureIndex { type: 1, key: 1 }, ->

    
host = process.argv[2]
port = process.argv[3]
           
app.listen(port)
