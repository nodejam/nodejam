co = require 'co'
koa = require 'koa'
route = require 'koa-route'
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

    utils.log "Fora API started at #{new Date} on #{host}:#{port}"

    app = koa()
    init = require '../common/web/init'
    init app

    #Routes
    m_credentials = require './controllers/credentials'
    m_users = require './controllers/users'
    m_forums = require './controllers/forums'
    m_posts = require './controllers/posts'
    m_images = require './controllers/images'

    app.use route.get '/api/v1/healthcheck', -> this.body { jacksparrow: "alive" }

    app.use route.post '/api/v1/credentials', m_credentials.create

    app.use route.post '/api/v1/users', m_users.create
    app.use route.get '/api/v1/users/:username', m_users.item

    app.use route.post '/api/v1/forums', m_forums.create
    app.use route.post '/api/v1/forums/:forum/members', m_forums.join
    app.use route.post '/api/v1/forums/:forum', m_posts.create
    app.use route.put '/api/v1/forums/:forum/posts/:post', m_posts.edit

    app.use route.post '/api/v1/images', m_images.upload

    app.use route.put "/api/v1/admin/posts/:id", m_posts.admin_update

    #Start
    app.listen port
)()


