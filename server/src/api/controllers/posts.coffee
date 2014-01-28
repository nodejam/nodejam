conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
typeUtils = require('../../models/foratypeutils').ForaTypeUtils
utils = require '../../lib/utils'
auth = require '../../common/web/auth'


exports.create = auth.handler { session: true }, (forum) ->*
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db

    post = yield models.Post.create {
        type: yield @parser.body('type'),
        createdBy: @session.user,
        state: yield @parser.body('state'),
        rating: 0,
        savedAt: Date.now()
    }
    
    yield @parser.map post, yield getMappableFields yield post.getTypeDefinition()
    post = yield forum.addPost post
    this.body = post



exports.edit = auth.handler { session: true }, (forum, id) ->*
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db
    post = yield models.Post.getById(id, { user: @session.user }, db)
    
    if post
        if (post.createdBy.username is @session.user.username) 
            post.savedAt = Date.now()                       
            yield @parser.map post, yield getMappableFields yield post.getTypeDefinition()
            if yield @parser.body('state') is 'published'
                post.state = 'published'
            post = yield post.save()
            this.body = post
        else
            this.body = 'ACCESS_DENIED'
    else
        this.body = 'ACCESS_DENIED'



getMappableFields = (typeDef, acc = [], prefix = []) ->*
    typeUtils = models.Post.getTypeUtils()
    
    for field, def of typeDef.schema.properties
        if not (typeDef.inheritedProperties?.indexOf(field) >= 0)
            if typeUtils.isPrimitiveType def.type
                if def.type is 'array' and typeUtils.isCustomType def.items.type
                        prefix.push field
                        yield getMappableFields def.items.typeDefinition, acc, prefix
                        prefix.pop field
                else
                    acc.push prefix.concat(field).join '_'
            else
                if typeUtils.isCustomType def.type
                    prefix.push field
                    yield getMappableFields def.typeDefinition, acc, prefix
                    prefix.pop field 
    acc

    
exports.remove = auth.handler { session: true }, (post) ->*
    post = yield models.Post.getById(post, { user: @session.user }, db)
    if post
        if (post.createdBy.username is @session.user.username) or @session.admin
            post = yield post.destroy()
            this.body = post
        else
            this.body = 'ACCESS_DENIED'
    else
        this.body = 'INVALID_POST'
                 

        
exports.addComment = auth.handler { session: true }, (id) ->*
    contentType = forum.settings?.comments?.contentType ? 'text'
    if contentType is 'text'
        post = yield models.Post.getById(id, { user: @session.user }, db)
        comment = new models.Comment()
        comment.createdBy = @session.user
        comment.forum = forum.stub
        comment.itemid = post._id.toString()
        comment.data = yield @parser.body('data')
        comment = yield comment.save({ user: @session.user }, db)
        this.body = comment



#Admin Features
exports.admin_update = auth.handler { admin: true }, (id) ->*
    post = yield models.Post.getById(id, { user: @session.user }, db)
    if post 
        meta = yield @parser.body('meta')
        if meta
            post = yield post.addMetaList meta.split(',')
        this.body = post
    else
        this.body = 'INVALID_POST'

