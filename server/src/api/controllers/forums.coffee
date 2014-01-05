conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'

exports.create = auth.handler { session: true }, ->*
    creds = { user: @session.user }
    stub = @parser.body('name').toLowerCase().trim().replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')
    forum = yield models.Forum.get({ network: @network.stub, $or: [{ stub }, { name: @parser.body('name') }] }, creds, db)
    if forum
        throw new Error "FORUM_EXISTS"
    else
        forum = new models.Forum
        forum.network = @network.stub
        forum.stub = stub
        @parser.map forum, ['name', 'type', 'description', 'postTypes', 'cover_image_src', 'cover_image_small', 'cover_alt', 'cover_image_credits']
        forum.createdBy = @session.user
        
        forum = yield forum.save creds, db
        yield forum.addRole @session.user, 'admin'
        
        info = new models.ForumInfo {
            forumid: forum._id.toString(),
            message: @parser.body('message'),
            about: @parser.body('about')
        }
        yield info.save creds, db        
        this.body = forum


                
exports.edit = auth.handler { session: true }, (stub) ->*
    forum = yield models.Forum.get({ stub, network: @network.stub }, { user: @session.user }, db)
    if (@session.user.username is forum.createdBy.username) or @session.admin
        forum.description = @parser.body('description')
        @parser.map forum, ['description', 'postTypes', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']     
        forum = yield forum.save()
        this.body = forum
    else
        throw new Error "ACCESS_DENIED"
                    
          
                    
exports.remove = auth.handler { session: true }, (stub) ->*
    forum = yield models.Forum.get({ stub, network: @network.stub }, { user: @session.user }, db)
    if @session.admin
        yield forum.destroy()
        this.body = { success: true }
    else
        throw new Error "ACCESS_DENIED"



exports.join = auth.handler { session: true }, (stub) ->*
    forum = yield models.Forum.get({ stub, network: @network.stub }, { user: @session.user }, db)
    yield forum.join @session.user
    this.body = { success: true }
                        
