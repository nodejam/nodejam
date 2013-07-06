http = require('http')
path = require 'path'
fs = require 'fs'
querystring = require 'querystring'
async = require '../../common/async'
utils = require '../../common/utils'
data = require './data'
conf = require '../../conf'

database = new (require '../../common/database').Database(conf.db)

console.log "Setup started at #{new Date}"
console.log "NODE_ENV is #{process.env.NODE_ENV}"
console.log "Setup will connect to database #{conf.db.name} on #{conf.db.host}"

HOST = 'local.foraproject.org'
PORT = '80'

if process.env.NODE_ENV isnt 'development'
    console.log 'Setup can only be run in development.'
    process.exit()
    
if HOST isnt 'local.foraproject.org'
    console.log 'HOST should be local.'
    process.exit()
    

init = () ->
    _globals = {}

    if '--delete' in process.argv        
        database.getDb (err, db) ->
            console.log 'Deleting main database.'
            db.dropDatabase (err, result) ->
                console.log 'Everything is gone now.'
                process.exit()

    else if '--create' in process.argv
        console.log 'This script will setup basic data. Calls the latest HTTP API.'

        #Create Users
        _globals.sessions = {}

        createUser = (user, cb) ->
            console.log "Creating #{user.username}..." 
            user.secret = conf.networks[0].adminkeys.default
            doHttpRequest '/api/sessions', querystring.stringify(user), 'post', (err, resp) ->   
                resp = JSON.parse resp             
                console.log "Created #{resp.username}"
                _globals.sessions[user.username] = resp
                cb()
        
        createUserTasks = []
        for user in data.users
            do (user) ->
                createUserTasks.push (cb) ->
                    createUser user, cb
                    
        createForum = (forum, cb) ->
            passkey = _globals.sessions[forum._createdBy].passkey
            console.log "Creating a new forum with passkey(#{passkey})...."
            console.log "Creating #{forum.name}..."
            
            delete forum._createdBy
            
            doHttpRequest "/api/forums?passkey=#{passkey}", querystring.stringify(forum), 'post', (err, resp) ->                
                resp = JSON.parse resp            
                console.log "Created #{resp.name}"
                cb()
            
        createForumTasks = []
        for forum in data.forums
            do (forum) ->
                createForumTasks.push (cb) ->
                    createForum forum, cb
            
        createArticle = (article, cb) ->
            passkey = _globals.sessions[article._createdBy].passkey
            console.log "Creating a new article with passkey(#{passkey})...."
            console.log "Creating #{article.title}..."
            
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
                console.log "Created #{resp.title} with uid #{resp.uid}"
                if meta.split(',').indexOf('featured') > -1
                    doHttpRequest "/api/admin/feature?passkey=#{passkey}&forum=#{resp.forums[0].stub}&uid=#{resp.uid}", null, 'get', (err, r) ->                
                        resp = JSON.parse resp
                        console.log "Added featured tag to article #{resp.title}."
                        cb()
                
        createArticleTasks = []
        for article in data.articles
            do (article) ->
                createArticleTasks.push (cb) ->
                    createArticle article, cb            
                            
        tasks = ->
            async.series createUserTasks, ->
                console.log 'Created users.'
                async.series createForumTasks, ->
                    console.log 'Created forums.'
                    async.series createArticleTasks, ->
                        console.log 'Created articles.'
                        console.log 'Setup complete.'
        
        console.log 'Setup will begin in 3 seconds.'
        setTimeout tasks, 1000
    else
        console.log 'Invalid option.'
        process.exit()  
            


doHttpRequest = (url, data, method, cb) ->
    console.log "HTTP #{method.toUpperCase()} to #{url}"
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
            console.log response
            cb null, response

    if data
        req.write(data)

    req.end()        

init()
