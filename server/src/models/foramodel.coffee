BaseModel = require '../lib/data/basemodel'
DatabaseModel = require '../lib/data/databasemodel'
typeUtils = require('./foratypeutils').typeUtils
                                        
class ForaModel extends BaseModel
    
    @getTypeUtils: ->
        typeUtils



class ForaDbModel extends DatabaseModel

    @getTypeUtils: ->
        typeUtils


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
