#TODO: Cleanup this mess sometime

http = require('http')
path = require 'path'
fs = require 'fs'
querystring = require 'querystring'
co = require 'co'
thunkify = require 'thunkify'
logger = require '../../lib/logger'
data = require './data'
conf = require '../../conf'

logger.log "Setup started at #{new Date}"
logger.log "NODE_ENV is #{process.env.NODE_ENV}"
logger.log "Setup will connect to database #{conf.db.name} on #{conf.db.host}"
argv = require('optimist').argv

HOST = argv.host ? 'local.foraproject.org'
PORT = if argv.port then parseInt(argv.port) else 80

logger.log "Setup will connect to #{HOST}:#{PORT}"

init = ->*
    ForaTypeUtils = require('../../models/foratypeutils')
    typeUtils = new ForaTypeUtils()
    yield typeUtils.init()

    odm = require('fora-models')
    database = new odm.Database conf.db, typeUtils.getTypeDefinitions()

    _globals = {}
    
    del = ->*
            if process.env.NODE_ENV is 'development'
                logger.log 'Deleting main database.'
                db = yield database.deleteDatabase()
                logger.log 'Everything is gone now.'
            else
                logger.log "Delete database can only be used if NODE_ENV is 'development'"

    create = ->*
            logger.log 'This script will setup basic data. Calls the latest HTTP API.'

            #Create Users
            _globals.sessions = {}

            _doHttpRequest = thunkify(doHttpRequest)
            for user in data.users
                logger.log "Creating a credential for #{user.username}..."
                    
                cred = {
                    secret: conf.auth.adminkeys.default,
                    type: user.credential_type
                }
                
                switch cred.type
                    when 'builtin'
                        cred.username = user.credential_username
                        cred.password = user.credential_password
                        cred.email = user.email
                    when 'twitter'
                        cred.username = user.credential_username
                        cred.id = user.credential_id
                        cred.accessToken = user.credential_accessToken
                        cred.accessTokenSecret = user.credential_accessTokenSecret
                        cred.email = user.email

                resp = yield _doHttpRequest '/api/v1/credentials', querystring.stringify(cred), 'post'            
                token = JSON.parse(resp).token

                resp = yield _doHttpRequest "/api/v1/users?token=#{token}", querystring.stringify(user), 'post'            
                resp = JSON.parse resp       
                logger.log "Created #{resp.username}"
                _globals.sessions[user.username] = resp
                
                logger.log "Creating session for #{resp.username}"
                resp = yield _doHttpRequest "/api/v1/login?token=#{token}", querystring.stringify({ token, username: user.username }), 'post'            
                _globals.sessions[user.username].token = JSON.parse(resp).token

            forums = {}
            for forum in data.forums
                token = _globals.sessions[forum._createdBy].token
                logger.log "Creating a new forum #{forum.name} with token #{token}...."
                delete forum._createdBy
                if forum._message
                    forum.message = fs.readFileSync path.resolve(__dirname, "forums/#{forum._message}"), 'utf-8'                    
                delete forum._message
                if forum._about
                    forum.about = fs.readFileSync path.resolve(__dirname, "forums/#{forum._about}"), 'utf-8'                    
                delete forum._about
                forum.type = 'forums/simple/1.0.0'
                resp = yield _doHttpRequest "/api/v1/forums?token=#{token}", querystring.stringify(forum), 'post'
                forumJson = JSON.parse resp
                forums[forumJson.stub] = forumJson
                logger.log "Created #{forumJson.name}"
                
                for u, uToken of _globals.sessions
                    if uToken.token isnt token
                        resp = yield _doHttpRequest "/api/v1/forums/#{forumJson.stub}/members?token=#{uToken.token}", querystring.stringify(forum), 'post'
                        resp = JSON.parse resp
                        logger.log "#{u} joined #{forum.name}"
            
            for article in data.articles                    
                token = _globals.sessions[article._createdBy].token
                adminkey = _globals.sessions['jeswin'].token
                
                logger.log "Creating a new article with token #{token}...."
                logger.log "Creating #{article.title}..."
                
                article.content_text = fs.readFileSync path.resolve(__dirname, "articles/#{article._content}"), 'utf-8'
                article.content_format = 'markdown'
                article.state = 'published'
                forum = article._forum
                meta = article._meta
                            
                delete article._forum
                delete article._createdBy
                delete article._content
                delete article._meta
                
                
                resp = yield _doHttpRequest "/api/v1/forums/#{forum}?token=#{token}", querystring.stringify(article), 'post'            
                resp = JSON.parse resp
                logger.log "Created #{resp.title} with stub #{resp.stub}"
                
                for metaTag in meta.split(',')
                    resp = yield _doHttpRequest "/api/v1/admin/forums/#{forum}/posts/#{resp.stub}?token=#{adminkey}", querystring.stringify({ meta: metaTag}), 'put'        
                    resp = JSON.parse resp
                    logger.log "Added #{metaTag} tag to article #{resp.title}."
                    
            #Without this return, CS will create a wrapper function to return the results (array) of: for metaTag in meta.split(',')
            return


    if argv.delete
        yield del()
        process.exit()

    else if argv.create
        yield create()
        process.exit()

    else if argv.recreate
            yield del()
            yield create()
            process.exit()
    else
        logger.log 'Invalid option.'
        process.exit()  
            


doHttpRequest = (url, data, method, cb) ->
    logger.log "HTTP #{method.toUpperCase()} to #{url}"
    options = {
        host: HOST,
        port: PORT,
        path: url,
        method: method,
        headers: if data then { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': data.length } else { 'Content-Type': 'application/x-www-form-urlencoded', 'Content-Length': 0 }            
    }

    response = ''
    
    req = http.request options, (res) ->
        res.setEncoding('utf8')
        res.on 'data', (chunk) ->
            response += chunk
            
        res.on 'end', ->
            logger.log response
            cb null, response

    if data
        req.write(data)

    req.end()        

(co ->*
    yield init()
)()
