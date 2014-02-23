Mongo = require 'mongodb'
thunkify = require 'thunkify'
utils = require '../../../utils'
Parser = require './queryparser'

class MongoDb
    constructor: (@conf, @typeDefinitions) ->



    getDb: =>*
        if not @db
            client = new Mongo.Db(@conf.name, new Mongo.Server(@conf.host, @conf.port, {}), { safe: true })
            @db = yield thunkify(client.open).call client
            @parser = new Parser(@typeDefinitions)
        @db



    insert: (typeDefinition, document) =>*
        db = yield @getDb()
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        result = yield thunkify(collection.insert).call collection, document, { safe: true }
        result[0]
        
        

    update: (typeDefinition, query, document) =>*
        db = yield @getDb()
        query = @parser.parse(query, typeDefinition)
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        yield thunkify(collection.update).call collection, query, document, { safe: true, multi: false }



    updateAll: (typeDefinition, query, document) =>*
        db = yield @getDb()
        query = @parser.parse(query, typeDefinition)
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        yield thunkify(collection.update).call collection, query, document, { safe: true, multi: true }



    count: (typeDefinition, query) =>*
        cursor = yield @getCursor typeDefinition, query
        yield thunkify(cursor.count).call cursor
        
        
    
    find: (typeDefinition, query, options = {}) =>*
        cursor = yield @getCursor typeDefinition, query, options
        yield thunkify(cursor.toArray).call cursor            



    findOne: (typeDefinition, query, options = {}) =>*
        cursor = yield @getCursor typeDefinition, query, options
        yield thunkify(cursor.nextObject).call cursor            



    remove: (typeDefinition, query, options = {}) =>*
        db = yield @getDb()
        query = @parser.parse(query, typeDefinition)
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        yield thunkify(collection.remove).call collection, query, { safe:true }



    deleteDatabase: =>*
        db = yield @getDb()
        yield (thunkify db.dropDatabase).call(db)



    setupIndexes: =>*        
        db = yield @getDb()
        utils.log "Setting up indexes for mongodb"

        for name, typeDefinition of @typeDefinitions
            if typeDefinition.indexes
                collection = yield thunkify(db.collection).call db, typeDefinition.collection
                for index in typeDefinition.indexes
                    yield thunkify(collection.ensureIndex).call collection, index

                utils.log typeDefinition.collection + ": " + JSON.stringify yield thunkify(collection.indexInformation).call collection         
        return
        
    
                    
    ObjectId: (id) =>
        if id
            if typeof id is "string" then new Mongo.ObjectID(id) else id
        else
            new Mongo.ObjectID()



    getCursor: (typeDefinition, query, options = {}) =>*
        db = yield @getDb()
        query = @parser.parse(query, typeDefinition)
        collection = yield thunkify(db.collection).call db, typeDefinition.collection
        cursor = collection.find query
        if options.sort
            cursor = cursor.sort options.sort
        if cursor.limit
            cursor = cursor.limit options.limit
        cursor



module.exports = MongoDb
