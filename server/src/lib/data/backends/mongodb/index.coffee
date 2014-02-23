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



    insert: (typeDefinition, document) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        result = yield thunkify(collection.insert).call collection, document, { safe: true }
        result[0]
        
        

    update: (typeDefinition, params, document) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        yield thunkify(collection.update).call collection, params, document, { safe: true, multi: false }



    updateAll: (typeDefinition, params, document) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        yield thunkify(collection.update).call collection, params, document, { safe: true, multi: true }



    find: (typeDefinition, query) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        collection.find query



    findWithOptions: (typeDefinition, query, options) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        collection.find query, options
        


    findOne: (typeDefinition, query) =>*
        cursor = yield @find(typeDefinition, query)
        yield thunkify(cursor.nextObject).call cursor



    remove: (typeDefinition, params) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        yield thunkify(collection.remove).call collection, params, { safe:true }



    setupIndexes: (indexes) =>*        
        db = yield @getDb()
        utils.log "Setting up indexes for mongodb"
        for typeDefinition, list of indexes
            collection = yield thunkify(db.collection).call db, typeDefinition.collection
            for index in list
                yield thunkify(collection.ensureIndex).call collection, index

            utils.log typeDefinition + ": " + JSON.stringify yield thunkify(collection.indexInformation).call collection         
        return
        
    
                    
    ObjectId: (id) =>
        if id
            if typeof id is "string" then new Mongo.ObjectID(id) else id
        else
            new Mongo.ObjectID()


module.exports = Database
