odm = require('fora-models')

class ForaModel extends odm.BaseModel

    @getTypesService: ->
        typesService



class ForaDbModel extends odm.DatabaseModel


    @getTypesService: ->
        typesService


exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
