Mongo = require 'mongodb'
utils = require './utils'

class Database
    constructor: (@conf) ->


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



    insert: (collectionName, document, cb) =>
        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.insert document, { safe: true }, (e, r) =>
                    cb? e, r?[0]
                    completionCallback(e)



    update: (collectionName, params, document, cb) =>
        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.update params, document, { safe: true, multi: false }, (e, r) =>
                    cb? e, r
                    completionCallback(e)



    updateAll: (collectionName, params, document, cb) =>
        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.update params, document, { safe: true, multi: true }, (e, r) =>
                    cb? e, r
                    completionCallback(e)



    find: (collectionName, query, cb) =>
        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                cursor = collection.find query
                cb? err, cursor
                completionCallback(err)
                


    findWithOptions: (collectionName, query, options, cb) =>
        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                cursor = collection.find(query, options)
                cb? err, cursor
                completionCallback(err)



    findOne: (collectionName, query, cb) =>     
        @find collectionName, query, (err, cursor) =>
            cursor.nextObject (err, item) =>
                cb? err, item



    remove: (collectionName, params, cb) =>
        @execute (db, completionCallback) =>
            db.collection collectionName, (err, collection) =>
                collection.remove params, { safe:true }, (e, r) ->
                    cb? e, r
                    completionCallback(e)
                    

                    
    incrementCounter: (key, cb) =>
        @execute (db, completionCallback) =>
            db.collection '_counters', (err, collection) =>
                collection.findAndModify { key: key }, {}, { $inc: { value: 1 } }, {}, (e, kvp) => 
                    cb? e, kvp.value
                    completionCallback(e)
                    


    ObjectId: (id) =>
        if id
            if typeof id is "string" then new Mongo.ObjectID(id) else id
        else
            new Mongo.ObjectID()


exports.Database = Database
