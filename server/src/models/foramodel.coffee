thunkify = require 'thunkify'
fs = require 'fs'
odm = require('fora-odm')
ForaTypeUtils = require('./foratypeutils')
typeUtils = new ForaTypeUtils()
                                        
class ForaModel extends odm.BaseModel
    
    @getTypeUtils: ->
        typeUtils



class ForaDbModel extends odm.DatabaseModel


    @getTypeUtils: ->
        typeUtils



    initialize: =>*
        @["typeDefinition"] = yield @getTypeDefinition()
        
    

exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel


