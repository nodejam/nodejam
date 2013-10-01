http = require('http')
path = require 'path'
fs = require 'fs'
querystring = require 'querystring'
utils = require '../../common/utils'
data = require './data'
conf = require '../../conf'
Q = require('../../common/q')

database = new (require '../../common/data/database').Database(conf.db)

utils.log "Setup started at #{new Date}"
utils.log "NODE_ENV is #{process.env.NODE_ENV}"
utils.log "Setup will connect to database #{conf.db.name} on #{conf.db.host}"
argv = require('optimist').argv

HOST = argv.host ? 'local.foraproject.org'
PORT = if argv.port then parseInt(argv.port) else 80

utils.log "Setup will connect to #{HOST}:#{PORT}"

init = () ->
    _globals = {}
    
    del = ->
        (Q.async ->
            if process.env.NODE_ENV is 'development'
                utils.log 'Deleting main database.'
                db = yield Q.nfcall database.getDb
                result = yield Q.ninvoke(db, "dropDatabase")
                utils.log 'Everything is gone now.'
            else
                utils.log "Delete database can only be used if NODE_ENV is 'development'"
        )()

    create = -> 
        (Q.async ->
            utils.log 'This script will setup basic data. Calls the latest HTTP API.'

            #Create Users
            _globals.sessions = {}

            for user in data.users
                utils.log "Creating #{user.username}..." 
                user.secret = conf.auth.adminkeys.default
                resp = yield Q.nfcall doHttpRequest, '/api/users', querystring.stringify(user), 'post'            
                resp = JSON.parse resp             
                utils.log "Created #{resp.username}"
                _globals.sessions[user.username] = resp

            for collection in data.collections
                token = _globals.sessions[collection._createdBy].token
                utils.log "Creating a new collection #{collection.name} with token(#{token})...."
                delete collection._createdBy
                if collection._message
                    collection.message = fs.readFileSync path.resolve(__dirname, "collections/#{collection._message}"), 'utf-8'                    
                delete collection._message
                if collection._about
                    collection.about = fs.readFileSync path.resolve(__dirname, "collections/#{collection._about}"), 'utf-8'                    
                delete collection._about
                resp = yield Q.nfcall doHttpRequest, "/api/collections?token=#{token}", querystring.stringify(collection), 'post'
                collectionJson = JSON.parse resp
                utils.log "Created #{collectionJson.name}"
                
                for u, uToken of _globals.sessions
                    if uToken.token isnt token
                        resp = yield Q.nfcall doHttpRequest, "/api/collections/#{collectionJson.stub}/members?token=#{uToken.token}", querystring.stringify(collection), 'post'
                        resp = JSON.parse resp
                        utils.log "#{u} joined #{collection.name}"
            
            for article in data.articles                    
                token = _globals.sessions[article._createdBy].token
                adminkey = _globals.sessions['jeswin'].token
                
                utils.log "Creating a new article with token(#{token})...."
                utils.log "Creating #{article.title}..."
                
                article.content = fs.readFileSync path.resolve(__dirname, "articles/#{article._content}"), 'utf-8'
                article.publish = true
                collection = article._collection
                
                meta = article._meta
                            
                delete article._collection
                delete article._createdBy
                delete article._content
                delete article._meta
                
                resp = yield Q.nfcall doHttpRequest, "/api/collections/#{collection}?token=#{token}", querystring.stringify(article), 'post'            
                resp = JSON.parse resp
                utils.log "Created #{resp.title} with id #{resp._id}"
                
                for metaTag in meta.split(',')
                    resp = yield Q.nfcall doHttpRequest, "/api/admin/records/#{resp._id}?token=#{adminkey}", querystring.stringify({ meta: metaTag}), 'put'        
                    resp = JSON.parse resp
                    utils.log "Added #{metaTag} tag to article #{resp.title}."
                    
            #Without this return, CS will create a wrapper function to return the results (array) of: for metaTag in meta.split(',')
            return)()


    if argv.delete
        (Q.async ->
            yield del()
            process.exit())()

    else if argv.create
        (Q.async ->
            yield create()
            process.exit())()

    else if argv.recreate
        (Q.async ->
            yield del()
            yield create()
            process.exit())()
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
