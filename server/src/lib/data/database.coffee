Mongo = require 'mongodb'
thunkify = require 'thunkify'

class Database

    constructor: (@conf) ->
        switch @conf.type
            when 'mongodb'
                Mongo = require('./backends/mongodb')                
                @db = new Mongo @conf


    getDb: =>*
        yield @db.getDb()



    insert: (collectionName, document) =>*
        yield @db.insert(collectionName, document)
        
        

    update: (collectionName, params, document) =>*
        yield @db.update(collectionName, params, document)



    updateAll: (collectionName, params, document) =>*
        yield @db.updateAll(collectionName, params, document)



    find: (collectionName, query) =>*
        yield @db.find(collectionName, query)



    findWithOptions: (collectionName, query, options) =>*
        yield @db.findWithOptions(collectionName, query, options)
        


    findOne: (collectionName, query) =>*
        yield @db.findOne(collectionName, query)



    remove: (collectionName, params) =>*
        yield @db.remove(collectionName, params)


                    
    ObjectId: (id) =>
        @db.ObjectId(id)


exports.Database = Database
