conf = require '../../conf'
db = require('../app').db
models = require '../../models'
fields = require '../../models/fields'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'

exports.create = auth.handler { session: true }, ->*
    creds = { user: @session.user }
    stub = (yield @parser.body 'name').toLowerCase().trim()
    if conf.reservedNames.indexOf(stub) > -1
        stub = "_" + stub
    stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')    
    forum = yield models.Forum.get({ network: @network.stub, $or: [{ stub }, { name: yield @parser.body('name') }] }, creds, db)
    if forum
        throw new Error "Forum exists"
    else
        forum = new models.Forum
        forum.network = @network.stub
        forum.stub = stub
        yield @parser.map forum, ['name', 'type', 'description', 'theme', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']
        forum.postTypes = (yield @parser.body 'posttypes').split(',')
        
        forum.createdById = @session.user.id
        forum.createdBy = @session.user
        
        forum = yield forum.save creds, db
        yield forum.addRole @session.user, 'admin'
        
        info = new models.ForumInfo {
            forumId: db.getRowId(forum),
            message: yield @parser.body('message'),
            about: yield @parser.body('about')
        }
        yield info.save creds, db        
        this.body = forum


                
exports.edit = auth.handler { session: true }, (forum) ->*
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db
    if (@session.user.username is forum.createdBy.username) or @session.admin
        forum.description = yield @parser.body('description')
        yield @parser.map forum, ['description', 'postTypes', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']     
        forum = yield forum.save()
        this.body = forum
    else
        throw new Error "Access denied"



exports.join = auth.handler { session: true }, (forum) ->*
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db
    yield forum.join @session.user
    this.body = { success: true }
                        
