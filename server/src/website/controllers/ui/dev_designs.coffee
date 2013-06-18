controller = require('../controller')
conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError

class Dev_Designs extends controller.Controller

    constructor: ->
    
    cover: (req, res, next) =>
        @attachUser arguments, =>
            res.render 'dev_designs/cover-content.hbs', { 
                pageName: 'welcome-page', 
                coverPage: true,
                coverPicture: 'http://farm9.staticflickr.com/8449/8039166184_a4e1b14bb8_h.jpg' }


exports.Dev_Designs = Dev_Designs
