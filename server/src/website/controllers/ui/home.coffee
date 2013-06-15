controller = require('../controller')
conf = require '../../../conf'
models = new (require '../../../models').Models(conf.db)
utils = require('../../../common/utils')
AppError = require('../../../common/apperror').AppError

class Home extends controller.Controller

    constructor: ->
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            res.render 'home/welcome.hbs', { 
                pageName: 'welcome-page', 
                coverPage: true,
                coverPicture: 'http://farm9.staticflickr.com/8449/8039166184_a4e1b14bb8_h.jpg' }


exports.Home = Home
