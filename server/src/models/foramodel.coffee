BaseModel = require('../lib/data/basemodel').BaseModel
DatabaseModel = require('../lib/data/databasemodel').DatabaseModel
ForaTypeUtils = require('./foratypeutils').ForaTypeUtils
                                        

class ForaModel extends BaseModel
    
    @foraTypeUtils: new ForaTypeUtils()
    
    
    @getTypeUtils: ->
        @foraTypeUtils



class ForaDbModel extends DatabaseModel

    @foraTypeUtils: new ForaTypeUtils()
    
    
    @getTypeUtils: ->
        @foraTypeUtils


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
