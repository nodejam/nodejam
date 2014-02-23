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
        
        

    update: (typeDefinition, query, document) =>*
        yield @db.update(typeDefinition, query, document)



    updateAll: (typeDefinition, query, document) =>*
        yield @db.updateAll(typeDefinition, query, document)



    count: (typeDefinition, query) =>*
        yield @db.count(typeDefinition, query)
        


    find: (typeDefinition, query, options) =>*
        yield @db.find(typeDefinition, query, options)



    findOne: (typeDefinition, query, options) =>*
        yield @db.findOne(typeDefinition, query, options)



    remove: (typeDefinition, query) =>*
        yield @db.remove(typeDefinition, query)



    deleteDatabase: =>*
        yield @db.deleteDatabase()    


    setupIndexes: =>*
        yield @db.setupIndexes()
        
        
                    
    ObjectId: (id) =>
        @db.ObjectId(id)


module.exports = Database
