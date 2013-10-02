BaseModel = require('../common/data/basemodel').BaseModel
DatabaseModel = require('../common/data/databasemodel').DatabaseModel
Q = require('../common/q')

class ForaModel extends BaseModel



class ForaDbModel extends DatabaseModel

    getExtendedField = (obj, name, context, db) ->
        { context, db } = obj.getContext context, db
        desc = obj.getTypeDefinition()
        fieldDef = desc.extendedFields.fields[name]
        (Q.async =>
            yield fieldDef.model.get { parentid: obj._id.toString(), field: name }, context, db
        )()             
        


    getField: (name, context, db) =>
        (Q.async =>
            { context, db } = @getContext context, db
            (yield getExtendedField @, name, context, db)?.value
        )()        



    saveField: (name, value, context, db) =>
        { context, db } = @getContext context, db

        desc = @getTypeDefinition()
        fieldDef = desc.extendedFields.fields[name]
        errors = @validateField value, name, fieldDef
        
        (Q.async =>
            if not errors.length
                extendedField = yield getExtendedField @, name, context, db
                extendedField ?= new fieldDef.model {
                    parentid: @_id.toString(),
                    field: name
                }
                extendedField.value = value
                yield extendedField.save context, db
            else
                @onError errors, desc
        )()        


    deleteField: (name, context, db) =>
        (Q.async =>
            extendedField = yield getExtendedField @, name, context, db
            yield extendedField?.destroy()
        )()     
        

exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
