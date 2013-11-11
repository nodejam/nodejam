conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
Q = require('../../lib/q')
Controller = require('../../common/web/controller').Controller

class Records extends Controller
    
    item: (req, res, next) =>
        @attachUser arguments, =>
            (Q.async =>
                try                
                    forum = yield models.Forum.get({ stub: req.params('forum'), network: req.network.stub }, {}, db)
                    if forum
                        record = yield models.Record.get({ 'forum.id': forum._id.toString(), stub: req.params('stub') }, {}, db)
                        if record
                            author = yield models.User.getById record.createdBy.id, {}, db
                            
                            template = record.getTemplate 'standard'
                            html = template.render {
                                record,
                                author,
                                forum
                            }
                            
                            res.render req.network.getView('records', 'record'), { 
                                html,
                                json: JSON.stringify(record),
                                typeDefinition: JSON.stringify(record.getTypeDefinition()),
                                user: req.user,
                                pageName: 'record-page',
                                pageType: 'std-page'
                            }
                        else
                            res.send 404
                    else
                        res.send 404
                catch e
                    next e)()
            
        
            
exports.Records = Records
