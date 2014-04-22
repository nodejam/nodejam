co = require 'co'
koa = require 'koa'
route = require 'koa-route'
utils = require '../lib/utils'
conf = require '../conf'
ForaTypeUtils = require('../models/foratypeutils')
typeUtils = new ForaTypeUtils()
Loader = require('../app-lib/extensions/loader')
loader = new Loader()
    
(co ->*
    yield typeUtils.init()
    yield loader.init()
    
    orm = require('../lib/fora-orm')
    exports.db = new orm.Database(conf.db, typeUtils.getTypeDefinitions())
    
    process.chdir __dirname
    host = process.argv[2]
    port = process.argv[3]

    if not host or not port
        utils.log "Usage: app.js host port"
        process.exit()

    utils.log "Fora API started at #{new Date} on #{host}:#{port}"

    app = koa()
    init = require '../app-lib/web/init'
    init app
    
    #monitoring and debugging
    if process.env.NODE_ENV is 'development'
        instance = utils.uniqueId()
        since = Date.now()
    else
        instance = '00000000'
        since = 0

    app.use route.get '/api/v1/healthcheck', ->* 
        uptime = parseInt((Date.now() - since)/1000) + "s"
        @body = { jacksparrow: "alive", instance, since, uptime }

    #Routes
    m_credentials = require './controllers/credentials'
    m_users = require './controllers/users'
    m_forums = require './controllers/forums'
    m_posts = require './controllers/posts'
    m_images = require './controllers/images'

    #credentials and users
    app.use route.post '/api/v1/credentials', m_credentials.create
    app.use route.post '/api/v1/users', m_users.create
    app.use route.post '/api/v1/login', m_users.login    
    app.use route.get '/api/v1/users/:username', m_users.item

    #forums
    app.use route.post '/api/v1/forums', m_forums.create
    app.use route.post '/api/v1/forums/:forum/members', m_forums.join
    app.use route.post '/api/v1/forums/:forum', m_posts.create
    app.use route.put '/api/v1/forums/:forum/posts/:post', m_posts.edit

    #images
    app.use route.post '/api/v1/images', m_images.upload

    #admin
    app.use route.put "/api/v1/admin/forums/:forum/posts/:post", m_posts.admin_update

    #Start
    app.listen port
)()


