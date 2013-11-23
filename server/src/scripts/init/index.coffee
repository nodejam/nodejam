conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
utils = require '../../lib/utils'
fs = require 'fs'
path = require 'path'
fsutils = require '../../common/fsutils'

#create directories
today = Date.now()
for p in (fsutils.getBasePath(x) for x in ['assetpaths', 'images', 'originalimages'])
    for i in [0..999] by 1    
        do (p) ->
            do (i) ->
                newPath = path.join p, "#{i}"
                fs.exists newPath, (exists) ->
                    if not exists
                        fs.mkdir newPath, ->
                        utils.log "Created #{newPath}"
                    else
                        utils.log "#{newPath} exists"
    
#Ensure indexes.
db.getDb (err, db) ->
    db.forum 'sessions', (_, coll) ->
        coll.ensureIndex { passkey: 1 }, ->
        coll.ensureIndex { accessToken: 1 }, ->

    db.forum 'users', (_, coll) ->
        coll.ensureIndex { 'username': 1 }, ->

    db.forum 'forums', (_, coll) ->
        coll.ensureIndex { 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1, 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'network': 1 }, ->
        coll.ensureIndex { 'stub': 1, 'network': 1 }, ->

    db.forum 'posts', (_, coll) ->
        coll.ensureIndex { state: 1, 'forum.stub': 1 }, ->
        coll.ensureIndex { state: 1, 'forum.id': 1 }, ->
        coll.ensureIndex { state: 1, savedAt: 1, 'forum.stub': 1 }, ->
        coll.ensureIndex { state: 1, savedAt: 1, 'forum.id': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1 }, ->
        
    db.forum 'messages', (_, coll) ->
        coll.ensureIndex { userid: 1 }, ->
        
    db.forum 'tokens', (_, coll) ->
        coll.ensureIndex { key: 1 }, ->

setTimeout (-> process.exit()), 5000
