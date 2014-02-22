Mongo = require 'mongodb'
thunkify = require 'thunkify'
utils = require '../../../utils'

class Database
    constructor: (@conf) ->


    getDb: =>*
        if not @db
            client = new Mongo.Db(@conf.name, new Mongo.Server(@conf.host, @conf.port, {}), { safe: true })
            @db = yield thunkify(client.open).call client
        @db



    insert: (collectionName, document) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, collectionName
        result = yield thunkify(collection.insert).call collection, document, { safe: true }
        result[0]
        
        

    update: (collectionName, params, document) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, collectionName
        yield thunkify(collection.update).call collection, params, document, { safe: true, multi: false }



    updateAll: (collectionName, params, document) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, collectionName
        yield thunkify(collection.update).call collection, params, document, { safe: true, multi: true }



    find: (collectionName, query) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, collectionName
        collection.find query



    findWithOptions: (collectionName, query, options) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, collectionName
        collection.find query, options
        


    findOne: (collectionName, query) =>*
        cursor = yield @find(collectionName, query)
        yield thunkify(cursor.nextObject).call cursor



    remove: (collectionName, params) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, collectionName
        yield thunkify(collection.remove).call collection, params, { safe:true }



    setupIndexes: (indexes) =>*        
        db = yield @getDb()
        utils.log "Setting up indexes for mongodb"
        for collectionName, list of indexes
            collection = yield thunkify(db.collection).call db, collectionName
            for index in list
                yield thunkify(collection.ensureIndex).call collection, index

            utils.log JSON.stringify yield thunkify(collection.indexInformation).call collection                
        return
        
    
                    
    ObjectId: (id) =>
        if id
            if typeof id is "string" then new Mongo.ObjectID(id) else id
        else
            new Mongo.ObjectID()


module.exports = Database
