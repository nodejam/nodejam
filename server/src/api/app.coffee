co = require 'co'
logger = require '../lib/logger'
argv = require('optimist').argv

host = process.argv[2]
port = process.argv[3]

if not host or not port
    logger.log "Usage: app.js host port"
    process.exit()

process.chdir __dirname

(co ->*
    koa = require 'koa'
    app = koa()

    #Error handling
    require('../lib/web/error')(app)

    #Conf, models, fields, typeUtils, loader
    conf = require '../conf'
    models = require '../models'
    fields = require '../models/fields'

    ForaTypeUtils = require('../models/foratypeutils')
    typeUtils = new ForaTypeUtils()
    yield* typeUtils.init([models, fields], models.Forum, models.Post)

    Loader = require('fora-extensions').Loader
    loader = new Loader(typeUtils, { directory: require("path").resolve(__dirname, '../extensions') })
    yield* loader.init()

    odm = require('fora-models')
    db = new odm.Database(conf.db, typeUtils.getTypeDefinitions())


    #Mapper, auth, error
    commonArgs = { typeUtils, models, fields, db, conf }

    init = require('../lib/web/init')(commonArgs)
    app.use init

    auth = require('../lib/web/auth')(commonArgs)

    Mapper = require('../lib/web/mapper')
    mapper = new Mapper(typeUtils)

    #monitoring and debugging
    if process.env.NODE_ENV is 'development'
        randomizer = require '../lib/randomizer'
        instance = randomizer.uniqueId()
        since = Date.now()
    else
        instance = '00000000'
        since = 0

    #Routes
    route = require 'koa-route'
    app.use route.get '/api/v1/healthcheck', ->*
        uptime = parseInt((Date.now() - since)/1000) + "s"
        @body = { jacksparrow: "alive", instance, since, uptime }

    conrollerArgs = {typeUtils, models, fields, db, conf, auth, mapper, loader }
    m_credentials = require('./controllers/credentials') conrollerArgs
    m_users = require('./controllers/users') conrollerArgs
    m_forums = require('./controllers/forums') conrollerArgs
    m_posts = require('./controllers/posts') conrollerArgs
    m_images = require('./controllers/images') conrollerArgs

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
    logger.log "Fora API started at #{new Date} on #{host}:#{port}"
)()
