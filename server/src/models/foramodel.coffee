thunkify = require 'thunkify'
fs = require 'fs'
BaseModel = require '../lib/data/basemodel'
DatabaseModel = require '../lib/data/databasemodel'
ForaTypeUtils = require('./foratypeutils')
typeUtils = new ForaTypeUtils()
                                        
class ForaModel extends BaseModel
    
    @getTypeUtils: ->
        typeUtils



class ForaDbModel extends DatabaseModel

    @getTypeUtils: ->
        typeUtils


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel


