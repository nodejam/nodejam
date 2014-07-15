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

    app.on 'error', (err) ->            
        console.log err
        console.log err.stack
    
    try
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
            
        #Mapper, auth            
        commonArgs = { typeUtils, models, fields, db, conf }

        init = require('../lib/web/init')(commonArgs)
        app.use init

        auth = require('../lib/web/auth')(commonArgs)

        Mapper = require('../lib/web/mapper')
        mapper = new Mapper(typeUtils)

        #layout        
        layout = require './layout'
        app.use (next) ->*
            @render = if argv.debugclient then layout.render_DEBUG else layout.render
            yield* next

        #monitoring and debugging
        if process.env.NODE_ENV is 'development'
            randomizer = require '../lib/randomizer'
            instance = randomizer.uniqueId()
            since = Date.now()
        else
            instance = '000000000'
            since = 0

        #Favicon
        favicon = require 'koa-favicon'        
        app.use favicon()

        #Routes
        route = require 'koa-route'
        app.use route.get '/healthcheck', ->* 
            uptime = parseInt((Date.now() - since)/1000) + "s"
            @body = { jacksparrow: "alive", instance, since, uptime }

        controllerArgs = {typeUtils, models, fields, db, conf, auth, mapper, loader }
        m_home = require('./controllers/home') controllerArgs
        m_auth = require('./controllers/auth') controllerArgs
        m_users = require('./controllers/users') controllerArgs
        m_forums = require('./controllers/forums') controllerArgs

        #health
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

        logger.log "Fora Website started at #{new Date} on #{host}:#{port}"
    
    catch err
        console.log err
        console.log err.stack
)()
