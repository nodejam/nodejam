co = require 'co'
koa = require 'koa'
favicon = require 'koa-favicon'
route = require 'koa-route'
logger = require '../lib/logger'
conf = require '../conf'
randomizer = require '../lib/randomizer'
ForaTypeUtils = require('../models/foratypeutils')
typeUtils = new ForaTypeUtils()
Loader = require('fora-extensions').Loader
extensionLoader = new Loader(typeUtils, { directory: require("path").resolve(__dirname, '../extensions') })
models = require '../models'
argv = require('optimist').argv
    
(co ->*
    yield typeUtils.init()
    yield extensionLoader.init()
    
    odm = require('fora-models')
    exports.db = new odm.Database(conf.db, typeUtils.getTypeDefinitions())
    
    process.chdir __dirname

    host = process.argv[2]
    port = process.argv[3]

    if not host or not port
        logger.log "Usage: app.js host port"
        process.exit()

    logger.log "Fora Website started at #{new Date} on #{host}:#{port}"

    app = koa()
    
    init = require '../lib/web/init'
    app.use init
    
    layout = require './layout'
    app.use (next) ->*
        @render = if argv.debug then layout.render_DEBUG else layout.render
        yield next

    app.on 'error', (err) ->
        console.log(err)

    app.use favicon()

    #monitoring and debugging
    if process.env.NODE_ENV is 'development'
        instance = randomizer.uniqueId()
        since = Date.now()
    else
        instance = '000000000'
        since = 0

    app.use route.get '/healthcheck', ->* 
        uptime = parseInt((Date.now() - since)/1000) + "s"
        @body = { jacksparrow: "alive", instance, since, uptime }

    #Routes
    m_home = require './controllers/home'
    m_auth = require './controllers/auth'
    m_users = require './controllers/users'
    m_forums = require './controllers/forums'

    app.use route.get '/healthcheck', -> this.body { "Jack Sparrow is alive" }

    #home
    app.use route.get '/', m_home.index
    
    #login
    app.use route.get '/login', m_home.login
    app.use route.get '/auth/twitter', m_auth.twitter
    app.use route.get '/auth/twitter/callback', m_auth.twitterCallback
    app.use route.get '/users/login', m_users.login

    #users
    app.use route.get '/~:username', m_users.item

    #forums
    app.use route.get '/forums', m_forums.index
    app.use route.get '/forums/new', m_forums.create
    app.use route.get '/:forum', m_forums.page
    app.use route.get '/:forum/:page', m_forums.page

    #Start
    app.listen port
)()
