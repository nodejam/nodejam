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

    if '--delete' in process.argv        
        database.getDb (err, db) ->
            utils.log 'Deleting main database.'
            db.dropDatabase (err, result) ->
                utils.log 'Everything is gone now.'
                process.exit()

    else if '--create' in process.argv
        utils.log 'This script will setup basic data. Calls the latest HTTP API.'

        #Create Users
        _globals.sessions = {}

        createUser = (user, cb) ->
            utils.log "Creating #{user.username}..." 
            user.secret = conf.auth.adminkeys.default
            doHttpRequest '/api/sessions', querystring.stringify(user), 'post', (err, resp) ->   
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
            passkey = _globals.sessions[forum._createdBy].passkey
            utils.log "Creating a new forum #{forum.name} with passkey(#{passkey})...."
            
            delete forum._createdBy
            
            doHttpRequest "/api/forums?passkey=#{passkey}", querystring.stringify(forum), 'post', (err, resp) ->                
                resp = JSON.parse resp            
                utils.log "Created #{resp.name}"
                cb()
            
        createForumTasks = []
        for forum in data.forums
            do (forum) ->
                createForumTasks.push (cb) ->
                    createForum forum, cb
            
        createArticle = (article, cb) ->
            passkey = _globals.sessions[article._createdBy].passkey
            adminkey = _globals.sessions['jeswin'].passkey
            
            utils.log "Creating a new article with passkey(#{passkey})...."
            utils.log "Creating #{article.title}..."
            
            article.content = fs.readFileSync path.resolve(__dirname, "articles/#{article._content}"), 'utf-8'
            article.publish = true
            forum = article._forum
            
            meta = article._meta
                        
            delete article._forum
            delete article._createdBy
            delete article._content
            delete article._meta
            
            doHttpRequest "/api/forums/#{forum}?passkey=#{passkey}", querystring.stringify(article), 'post', (err, resp) ->                
                resp = JSON.parse resp
                utils.log "Created #{resp.title} with id #{resp._id}"
                if meta.split(',').indexOf('featured') isnt -1
                    doHttpRequest "/api/admin/posts/#{resp._id}?passkey=#{adminkey}", querystring.stringify({ tags: 'featured'}), 'put', (err, resp) ->                
                        resp = JSON.parse resp
                        utils.log "Added featured tag to article #{resp.title}."
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
        
        utils.log 'Setup will begin in 3 seconds.'
        setTimeout tasks, 1000
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
