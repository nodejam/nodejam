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
        

class ExtensibleAppModel extends DatabaseAppModel

    getFieldPrefix = =>
        @constructor.getModelDescription().fieldPrefix
            
        

    getField: (name, context, db) =>
        (Q.async =>
            attachment = yield @getModels().Attachment.get { type: "#{getFieldPrefix()}.#{name}", key: @_id.toString() }, context, db
            attachment.value
        )()        
    


    saveField: (name, value, context, db) =>
        (Q.async =>
            attachment = yield @getModels().Attachment.get { type: "#{getFieldPrefix()}.#{name}", key: @_id.toString() }, context, db
            attachment.value = value
            yield attachment.save context, db
        )()        

        
    
    deleteField: (name, context, db) =>
        (Q.async =>
            attachment = yield @getModels().Attachment.get { type: "#{getFieldPrefix()}.#{name}", key: @_id.toString() }, context, db
            yield attachment.destroy context, db
        )()        

    
exports.AppModel = AppModel
exports.DatabaseAppModel = DatabaseAppModel
exports.ExtensibleAppModel = ExtensibleAppModel

