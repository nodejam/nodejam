controller = require('../controller')
conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError

class Forums extends controller.Controller

    constructor: ->
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            res.render 'forums/index.hbs', { 
                pageName: 'welcome-page', 
                coverPage: true,
                coverPicture: 'http://farm6.staticflickr.com/5470/9042287118_29dbe2a92b_h.jpg' }


exports.Forums = Forums
