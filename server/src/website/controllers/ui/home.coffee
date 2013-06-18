controller = require('../controller')
conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError

class Home extends controller.Controller

    constructor: ->
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            res.render 'home/index.hbs', {}


exports.Home = Home
