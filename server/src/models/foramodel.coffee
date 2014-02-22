BaseModel = require('../lib/data/basemodel').BaseModel
DatabaseModel = require('../lib/data/databasemodel').DatabaseModel
typeUtils = require('./foratypeutils').typeUtils
                                        

class ForaModel extends BaseModel
    
    @getTypeUtils: ->
        typeUtils



class ForaDbModel extends DatabaseModel

    @getTypeUtils: ->
        typeUtils


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
