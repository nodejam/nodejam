thunkify = require 'thunkify'
fs = require 'fs'
orm = require('../lib/fora-orm')
ForaTypeUtils = require('./foratypeutils')
typeUtils = new ForaTypeUtils()
                                        
class ForaModel extends orm.BaseModel
    
    @getTypeUtils: ->
        typeUtils



class ForaDbModel extends orm.DatabaseModel

    @getTypeUtils: ->
        typeUtils


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel


