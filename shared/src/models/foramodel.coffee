odm = require('fora-models')
ForaTypeService = require('./foratypeutils')
typeService = new ForaTypeService()

class ForaModel extends odm.BaseModel

    @getTypeService: ->
        typeService



class ForaDbModel extends odm.DatabaseModel


    @getTypeService: ->
        typeService


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
