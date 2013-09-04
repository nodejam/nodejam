BaseModel = require('../common/data/basemodel').BaseModel
DatabaseModel = require('../common/data/databasemodel').DatabaseModel
Q = require('../common/q')

class AppModel extends BaseModel
    
    @getModels: (path = './') =>
        if not @__models
            @__models = require path
        @__models
        
        
        
    getModels: (path = './') =>
        @constructor.getModels path
            


class DatabaseAppModel extends DatabaseModel

    @getModels: (path = './') =>
        if not @__models
            @__models = require path
        @__models
        
        
        
    getModels: (path = './') =>
        @constructor.getModels path      



    bindContext: (@__context, @__db) =>



    getContext: (context, db) =>
        { context: context ? @__context, db: db ? @__db }
        


class ExtensibleAppModel extends DatabaseAppModel

    getModelDescription = (obj) =>
        obj.constructor.getModelDescription().extendedFieldPrefix
        
        

    getField: (name, context, db) =>
        { context, db } = @getContext context, db
        (Q.async =>
            extendedField = yield @getModels().ExtendedField.get { type: "#{getModelDescription @}.#{name}", key: @_id.toString() }, context, db
            extendedField?.value
        )()        
    


    saveField: (name, value, context, db) =>
        { context, db } = @getContext context, db
        (Q.async =>
            extendedField = yield @getModels().ExtendedField.get { type: "#{getModelDescription @}.#{name}", key: @_id.toString() }, context, db
            extendedField ?= new (@getModels().ExtendedField) {
                type: "#{getModelDescription @}.#{name}",
                key: @_id.toString()
            }
            extendedField.value = value
            yield extendedField.save context, db
        )()        

        
    
    deleteField: (name, context, db) =>
        { context, db } = @getContext context, db
        (Q.async =>
            extendedField = yield @getModels().ExtendedField.get { type: "#{getModelDescription @}.#{name}", key: @_id.toString() }, context, db
            yield extendedField?.destroy context, db
        )()    
        
        
exports.AppModel = AppModel
exports.DatabaseAppModel = DatabaseAppModel
exports.ExtensibleAppModel = ExtensibleAppModel

