BaseModel = require './basemodel'
utils = require './utils'

class DatabaseModel extends BaseModel

    constructor: (params) ->
        utils.extend(this, params)


module.exports = DatabaseModel

