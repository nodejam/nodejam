odm = require('fora-models')
ForaTypesService = require('./foratypeutils')
typesService = new ForaTypesService()

class ForaModel extends odm.BaseModel

    @getTypesService: ->
        typesService



class ForaDbModel extends odm.DatabaseModel


    @getTypesService: ->
        typesService


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
