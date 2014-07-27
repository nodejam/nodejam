odm = require('fora-models')
ForaTypeUtils = require('./foratypeutils')
typeUtils = new ForaTypeUtils()

class ForaModel extends odm.BaseModel

    @getTypeUtils: ->
        typeUtils



class ForaDbModel extends odm.DatabaseModel


    @getTypeUtils: ->
        typeUtils


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
