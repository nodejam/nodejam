conf = require '../../../conf'
models = require '../../../models'
utils = require '../../../common/utils'
AppError = require('../../../common/apperror').AppError
controller = require '../controller'

class Forums extends controller.Controller

    constructor: ->
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            res.render 'forums/index.hbs', { 
                pageName: 'welcome-page', 
                coverPage: true,
                coverPicture: 'http://farm6.staticflickr.com/5470/9042287118_29dbe2a92b_h.jpg' }


exports.Forums = Forums
