conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require('../../lib/utils')
Q = require '../../lib/q'
Controller = require('../../common/web/controller').Controller


class Home extends Controller

    constructor: ->
    
    
    
    index: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try
                    editorsPicks = yield models.Record.find({ meta: 'pick', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 1), {}, db)
                    featured = yield models.Record.find({ meta: 'featured', 'forum.network': req.network.stub }, ((cursor) -> cursor.sort({ _id: -1 }).limit 12), {}, db)
                    featured = (f for f in featured when (x._id for x in editorsPicks).indexOf(f._id) is -1)

                    for record in editorsPicks.concat(featured)
                        template = record.getTemplate 'card'
                        record.html = template.render {
                            record,
                            forum: record.forum,
                        }

                    res.render req.network.getView('home', 'index'), { 
                        editorsPicks, 
                        featured, 
                        pageName: 'home-page', 
                        pageType: 'cover-page', 
                        cover: '/pub/images/cover.jpg'
                    }
                catch e
                    next e)()



    login: (req, res, next) =>
        res.render req.network.getView('home', 'login'), { 
            pageName: 'login-page', 
            pageType: 'std-page', 
        }



exports.Home = Home
