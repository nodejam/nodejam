conf = require '../../conf'
db = new (require '../../common/data/database').Database(conf.db)
utils = require '../../common/utils'

#Ensure indexes.
db.getDb (err, db) ->
    db.collection 'sessions', (_, coll) ->
        coll.ensureIndex { passkey: 1 }, ->
        coll.ensureIndex { accessToken: 1 }, ->

    db.collection 'users', (_, coll) ->
        coll.ensureIndex { 'username': 1 }, ->

    db.collection 'forums', (_, coll) ->
        coll.ensureIndex { 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1, 'network': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1, 'network': 1 }, ->
        coll.ensureIndex { 'stub': 1, 'network': 1 }, ->

    db.collection 'posts', (_, coll) ->
        coll.ensureIndex { state: 1, 'forum.stub': 1 }, ->
        coll.ensureIndex { state: 1, 'forum.id': 1 }, ->
        coll.ensureIndex { state: 1, publishedAt: 1, 'forum.stub': 1 }, ->
        coll.ensureIndex { state: 1, publishedAt: 1, 'forum.id': 1 }, ->
        coll.ensureIndex { 'createdBy.id': 1 }, ->
        coll.ensureIndex { 'createdBy.username': 1 }, ->
        
    db.collection 'messages', (_, coll) ->
        coll.ensureIndex { userid: 1 }, ->
        
    db.collection 'tokens', (_, coll) ->
        coll.ensureIndex { key: 1 }, ->

setTimeout (-> process.exit()), 3000
