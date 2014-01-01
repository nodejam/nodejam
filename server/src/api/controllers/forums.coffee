conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
Q = require '../../lib/q'
Controller = require('../../common/web/controller').Controller

class Forums extends Controller
    
    create: (req, res, next) =>
        @ensureSession arguments, =>            
            stub = req.body('name').toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')
            (Q.async =>*
                try
                    forum = yield models.Forum.get({ network: req.network.stub, $or: [{ stub }, { name: req.body('name') }] }, { user: req.user }, db)
                    if forum
                        res.send 'A Forum with the same name exists.'
                    else
                        forum = new models.Forum
                        forum.network = req.network.stub
                        forum.stub = stub
                        req.map forum, ['name', 'type', 'description', 'postTypes', 'cover_image_src', 'cover_image_small', 'cover_alt', 'cover_image_credits']
                        forum.createdBy = req.user
                        forum = yield forum.save { user: req.user }, db

                        yield forum.addRole req.user, 'admin'
                        
                        info = new models.ForumInfo {
                            forumid: forum._id.toString(),
                            message: req.body('message'),
                            about: req.body('about')
                        }
                        
                        yield info.save { user: req.user }, db
                        
                        res.send forum

                catch e
                    next e)()                            


                
    edit: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>*
                try
                    forum = yield models.Forum.get({ stub: req.params('forum'), network: req.network.stub }, { user: req.user }, db)
                    if req.user.username is forum.createdBy.username or @isAdmin(req.user)
                        forum.description = req.body('description')
                        req.map forum, ['description', 'postTypes', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']     
                        forum = yield forum.save()
                        res.send forum
                    else
                        next new Error "Access denied"
                catch e
                    next e)()
                    
          
                    
    remove: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>*
                try
                    forum = yield models.Forum.get({ stub: req.params('forum'), network: req.network.stub }, { user: req.user }, db)
                    if @isAdmin(req.user)
                        yield forum.destroy()
                        res.send { success: true }
                    else
                        next new Error "Access denied"
                catch e
                    next e)()



    join: (req, res, next) =>
        @ensureSession arguments, =>
            (Q.async =>*
                try
                    forum = yield models.Forum.get({ stub: req.params('forum'), network: req.network.stub }, { user: req.user }, db)
                    yield forum.join req.user
                    res.send { success: true }
                catch 
                    next e)()
                        

                
exports.Forums = Forums
