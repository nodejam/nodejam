conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
utils = require '../../common/utils'
fs = require 'fs'
path = require 'path'
fsutils = require '../../common/fsutils'

#create assetPaths for a whole year.
today = Date.now()
for i in [0..999] by 1
    do (i) ->
        newPath = path.join fsutils.assetBasePath, "#{i}"
        fs.exists newPath, (exists) ->
            if not exists
                fs.mkdir newPath, ->
                utils.log "Created #{newPath}"
    
#Ensure indexes.
db.getDb (err, db) ->
    db.collection 'sessions', (_, coll) ->
        coll.ensureIndex { passkey: 1 }, ->
        coll.ensureIndex { accessToken: 1 }, ->

    db.collection 'users', (_, coll) ->
        coll.ensureIndex { 'username': 1 }, ->

    db.collection 'collections', (_, coll) ->
        coll.ensureIndex { 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1, 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'network': 1 }, ->
        coll.ensureIndex { 'stub': 1, 'network': 1 }, ->

    db.collection 'records', (_, coll) ->
        coll.ensureIndex { state: 1, 'collection.stub': 1 }, ->
        coll.ensureIndex { state: 1, 'collection.id': 1 }, ->
        coll.ensureIndex { state: 1, savedAt: 1, 'collection.stub': 1 }, ->
        coll.ensureIndex { state: 1, savedAt: 1, 'collection.id': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1 }, ->
        
    db.collection 'messages', (_, coll) ->
        coll.ensureIndex { userid: 1 }, ->
        
    db.collection 'tokens', (_, coll) ->
        coll.ensureIndex { key: 1 }, ->

setTimeout (-> process.exit()), 5000
