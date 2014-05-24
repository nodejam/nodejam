BaseModel = require './basemodel'

class DatabaseModel extends BaseModel

    constructor: (params) ->
        utils.extend(this, params)


module.exports = DatabaseModel

