BaseModel = require('../lib/data/basemodel').BaseModel
DatabaseModel = require('../lib/data/databasemodel').DatabaseModel
ForaTypeUtils = require('./foratypeutils').ForaTypeUtils
                                        

class ForaModel extends BaseModel
    
    @getTypeUtils: ->
        ForaTypeUtils



class ForaDbModel extends DatabaseModel

    @getTypeUtils: ->
        ForaTypeUtils


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
