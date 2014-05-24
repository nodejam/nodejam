conf = require '../../conf'
db = require('../app').db
models = require '../../models'
fields = require '../../models/fields'
auth = require '../../lib/web/auth'
ForaTypeUtils = require('../../models/foratypeutils')
typeUtils = new ForaTypeUtils()
Mapper = require '../../lib/web/mapper'
mapper = new Mapper typeUtils

exports.create = auth.handler { session: 'user' }, ->*

    context = { user: @session.user }
    stub = (yield @parser.body 'name').toLowerCase().trim()
    
    if conf.reservedNames.indexOf(stub) > -1
        stub = stub + "-forum"
    stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'')    
    
    forum = yield models.Forum.get({ network: @network.stub, $or: [{ stub }, { name: yield @parser.body('name') }] }, context, db)

    if forum
        throw new Error "Forum exists"
    else
        forum = yield models.Forum.create {
            type: yield @parser.body('type'),
            name: yield @parser.body('name'),
            access: yield @parser.body('access'),
            network: @network.stub,
            stub,
            createdById: @session.user.id,
            createdBy: @session.user,
        }
        
        yield @parser.map forum, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']     
        yield @parser.map forum, yield mapper.getMappableFields yield forum.getTypeDefinition()        
        forum = yield forum.save context, db
        yield forum.addRole @session.user, 'admin'
        this.body = forum


                
exports.edit = auth.handler { session: 'user' }, (forum) ->*

    context = { user: @session.user }
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db
    
    if (@session.user.username is forum.createdBy.username) or @session.admin
        yield @parser.map forum, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']     
        yield @parser.map forum, yield mapper.getMappableFields yield forum.getTypeDefinition()
        forum = yield forum.save()
        @body = forum
    else
        @throw "access denied", 403



exports.join = auth.handler { session: 'user' }, (forum) ->*
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db
    yield forum.join @session.user
    @body = { success: true }
                        
