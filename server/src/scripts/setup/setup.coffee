http = require('http')
path = require 'path'
fs = require 'fs'
querystring = require 'querystring'
async = require '../../common/async'
utils = require '../../common/utils'
data = require './data'
conf = require '../../conf'

database = new (require '../../common/database').Database(conf.db)

utils.log "Setup started at #{new Date}"
utils.log "NODE_ENV is #{process.env.NODE_ENV}"
utils.log "Setup will connect to database #{conf.db.name} on #{conf.db.host}"

HOST = 'local.foraproject.org'
PORT = '80'

if process.env.NODE_ENV isnt 'development'
    utils.log 'Setup can only be run in development.'
    process.exit()
    
if HOST isnt 'local.foraproject.org'
    utils.log 'HOST should be local.'
    process.exit()
    

init = () ->
    _globals = {}
    
    del = (cb) ->
        database.getDb (err, db) ->
            utils.log 'Deleting main database.'
            db.dropDatabase (err, result) ->
                utils.log 'Everything is gone now.'
                cb()

    create = (cb) ->
        utils.log 'This script will setup basic data. Calls the latest HTTP API.'

        #Create Users
        _globals.sessions = {}

        createUser = (user, cb) ->
            utils.log "Creating #{user.username}..." 
            user.secret = conf.auth.adminkeys.default
            doHttpRequest '/api/users', querystring.stringify(user), 'post', (err, resp) ->   
                resp = JSON.parse resp             
                utils.log "Created #{resp.username}"
                _globals.sessions[user.username] = resp
                cb()
        
        createUserTasks = []
        for user in data.users
            do (user) ->
                createUserTasks.push (cb) ->
                    createUser user, cb
                    
        createForum = (forum, cb) ->
            token = _globals.sessions[forum._createdBy].token
            utils.log "Creating a new forum #{forum.name} with token(#{token})...."
            
            delete forum._createdBy
            
            doHttpRequest "/api/forums?token=#{token}", querystring.stringify(forum), 'post', (err, resp) ->                
                resp = JSON.parse resp            
                utils.log "Created #{resp.name}"
                cb()
            
        createForumTasks = []
        for forum in data.forums
            do (forum) ->
                createForumTasks.push (cb) ->
                    createForum forum, cb
            
        createArticle = (article, cb) ->
            token = _globals.sessions[article._createdBy].token
            adminkey = _globals.sessions['jeswin'].token
            
            utils.log "Creating a new article with token(#{token})...."
            utils.log "Creating #{article.title}..."
            
            article.content = fs.readFileSync path.resolve(__dirname, "articles/#{article._content}"), 'utf-8'
            article.publish = true
            forum = article._forum
            
            meta = article._meta
                        
            delete article._forum
            delete article._createdBy
            delete article._content
            delete article._meta
            
            doHttpRequest "/api/forums/#{forum}?token=#{token}", querystring.stringify(article), 'post', (err, resp) ->                
                resp = JSON.parse resp
                utils.log "Created #{resp.title} with id #{resp._id}"
                for metaTag in meta.split(',')
                    doHttpRequest "/api/admin/posts/#{resp._id}?token=#{adminkey}", querystring.stringify({ meta: metaTag}), 'put', (err, resp) ->                
                        resp = JSON.parse resp
                        utils.log "Added #{metaTag} tag to article #{resp.title}."
                        cb()

                
        createArticleTasks = []
        for article in data.articles
            do (article) ->
                createArticleTasks.push (cb) ->
                    createArticle article, cb            
                            
        tasks = ->
            async.series createUserTasks, ->
                utils.log 'Created users.'
                async.series createForumTasks, ->
                    utils.log 'Created forums.'
                    async.series createArticleTasks, ->
                        utils.log 'Created articles.'
                        utils.log 'Setup complete.'
                        cb()
                
        utils.log 'Setup will begin in 3 seconds.'
        setTimeout tasks, 1000
    
    if '--delete' in process.argv        
        del -> process.exit()
    else if '--create' in process.argv
        create -> process.exit()
    else if '--recreate' in process.argv
        del -> create -> process.exit()
    else
        utils.log 'Invalid option.'
        process.exit()  
            


doHttpRequest = (url, data, method, cb) ->
    utils.log "HTTP #{method.toUpperCase()} to #{url}"
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
            utils.log response
            cb null, response

    if data
        req.write(data)

    req.end()        

init()
