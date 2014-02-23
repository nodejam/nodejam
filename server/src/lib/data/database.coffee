Mongo = require 'mongodb'
thunkify = require 'thunkify'

class Database

    constructor: (@conf, @typeDefinitions) ->
        if not @typeDefinitions
            throw new Error "Pass typeDefinitions to the database backend"
            
        switch @conf.type
            when 'mongodb'
                Parser = require('./backends/mongodb')
                @db = new Parser @conf, @typeDefinitions



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



    deleteDatabase: =>*
        yield @db.deleteDatabase()    


    setupIndexes: =>*
        yield @db.setupIndexes()
        
        
                    
    ObjectId: (id) =>
        @db.ObjectId(id)


module.exports = Database
