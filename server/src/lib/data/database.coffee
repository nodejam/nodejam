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



    insert: (typeDefinition, document) =>*
        yield @db.insert(typeDefinition, document)
        
        

    update: (typeDefinition, params, document) =>*
        yield @db.update(typeDefinition, params, document)



    updateAll: (typeDefinition, params, document) =>*
        yield @db.updateAll(typeDefinition, params, document)



    find: (typeDefinition, query) =>*
        yield @db.find(typeDefinition, query)



    findWithOptions: (typeDefinition, query, options) =>*
        yield @db.findWithOptions(typeDefinition, query, options)
        


    findOne: (typeDefinition, query) =>*
        yield @db.findOne(typeDefinition, query)



    remove: (typeDefinition, params) =>*
        yield @db.remove(typeDefinition, params)



    setupIndexes: (indexes) =>*
        yield @db.setupIndexes(indexes)
        
        
                    
    ObjectId: (id) =>
        @db.ObjectId(id)


exports.Database = Database
