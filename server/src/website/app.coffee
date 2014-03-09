co = require 'co'
koa = require 'koa'
favicon = require 'koa-favicon'
route = require 'koa-route'
hbs = require 'koa-hbs'
utils = require '../lib/utils'
conf = require '../conf'
typeUtils = require('../models/foratypeutils').typeUtils
    
(co ->*
    yield typeUtils.init()
    Database = require '../lib/data/database'
    exports.db = new Database(conf.db, typeUtils.getTypeDefinitions())
    
    process.chdir __dirname

    host = process.argv[2]
    port = process.argv[3]

    if not host or not port
        utils.log "Usage: app.js host port"
        process.exit()

    utils.log "Fora Website started at #{new Date} on #{host}:#{port}"

    app = koa()
    init = require '../common/web/init'
    init app

    app.use favicon()

    app.use hbs.middleware {
      viewPath: __dirname + '/views',
      partialsPath: __dirname + '/views/partials',
      layoutsPath: __dirname + '/views/layouts',
      defaultLayout: 'default'
    }

    #monitoring and debugging
    if process.env.NODE_ENV is 'development'
        instance = utils.uniqueId()
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
    m_posts = require './controllers/posts'

    app.use route.get '/healthcheck', -> this.body { "Jack Sparrow is alive" }

    #home
    app.use route.get '/', m_home.index
    
    #login
    app.use route.get '/login', m_home.login
    app.use route.get '/auth/twitter', m_auth.twitter
    app.use route.get '/auth/twitter/callback', m_auth.twitterCallback
    app.use route.get '/users/login', m_users.loginForm
    app.use route.post '/users/login', m_users.login

    #users
    app.use route.get '/~:username', m_users.item

    #forums
    app.use route.get '/forums', m_forums.index
    app.use route.get '/forums/new', m_forums.create
    app.use route.get '/:forum', m_forums.item
    app.use route.get '/:forum/about', m_forums.about
    app.use route.get '/:forum/:post', m_posts.item

    #Register templates, helpers etc.
    require("./hbshelpers").register()

    #Start
    app.listen port
)()
