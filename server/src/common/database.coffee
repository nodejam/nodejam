Mongo = require 'mongodb'
utils = require './utils'
Q = require('./q')

class Database
    constructor: (@conf) ->


    _defer: (deferred, err, result) =>
        if err
            deferred.reject err
        else
            deferred.resolve result
        


    getDb: (cb) =>
        if not @db?
            client = new Mongo.Db(@conf.name, new Mongo.Server(@conf.host, @conf.port, {}), { safe: true })
            client.open (err, @db) =>
                cb err, @db
        else
            cb null, @db



    execute: (task) =>
        @getDb (err, db) =>
            try
                task db, (err) =>
            catch e
                utils.dumpError e



    insert: (collectionName, document) =>
        deferred = Q.defer()

        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.insert document, { safe: true }, (e, r) =>
                    @_defer deferred, e, r?[0]
                    completionCallback(e)

        deferred.promise
        
        

    update: (collectionName, params, document) =>
        deferred = Q.defer()

        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.update params, document, { safe: true, multi: false }, (e, r) =>
                    @_defer deferred, err, r
                    completionCallback(e)

        deferred.promise



    updateAll: (collectionName, params, document) =>
        deferred = Q.defer()

        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.update params, document, { safe: true, multi: true }, (e, r) =>
                    @_defer deferred, e, r
                    completionCallback(e)

        deferred.promise



    find: (collectionName, query) =>
        deferred = Q.defer()

        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                cursor = collection.find query
                @_defer deferred, err, cursor
                completionCallback(err)
                
        deferred.promise



    findWithOptions: (collectionName, query, options) =>
        deferred = Q.defer()

        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                cursor = collection.find(query, options)
                @_defer deferred, err, cursor
                completionCallback(err)

        deferred.promise



    findOne: (collectionName, query) =>     
        deferred = Q.defer()

        @find(collectionName, query)
            .then (cursor) =>
                cursor.nextObject (err, item) =>
                    @_defer deferred, err, item

        deferred.promise



    remove: (collectionName, params) =>
        deferred = Q.defer()

        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.remove params, { safe:true }, (e, r) ->
                    @_defer deferred, e, r
                    completionCallback(e)
                    
        deferred.promise


                    
    incrementCounter: (key) =>
        deferred = Q.defer()

        @execute (db, completionCallback) =>
            db.collection '_counters', (err, collection) =>
                collection.findAndModify { key: key }, {}, { $inc: { value: 1 } }, {}, (e, kvp) => 
                    @_defer deferred, e, kvp.value
                    completionCallback(e)
                    
        deferred.promise



    @ObjectId: (id) =>
        if id
            if typeof id is "string" then new Mongo.ObjectID(id) else id
        else
            new Mongo.ObjectID()


exports.Database = Database
