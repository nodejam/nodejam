conf = require '../../conf'
db = new (require '../../lib/data/database').Database(conf.db)
models = require '../../models'
utils = require '../../lib/utils'
auth = require '../../common/web/auth'

exports.create = auth.handler { session: true }, (forum) ->*
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db
    postType = yield @parser.body('type')
    typeDef = yield (yield models.Post.getTypeDefinition()).discriminator { type: postType }
    
    post = new typeDef.ctor {
        type: postType,
        createdBy: @session.user,
        state: yield @parser.body('state'),
        rating: 0,
        savedAt: Date.now()
    }
    
    @parser.map post, yield getMappableFields(typeDef)
    post = yield forum.addPost post
    this.body = post



exports.edit = auth.handler { session: true }, (forum, id) ->*
    forum = yield models.Forum.get { stub: forum, network: @network.stub }, { user: @session.user }, db
    post = yield models.Post.getById(id, { user: @session.user }, db)
    type = post.constructor
    
    if post
        if (post.createdBy.username is @session.user.username) or @session.admin
            post.savedAt = Date.now()                       
            @parser.map post, yield getMappableFields(type)
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
        if typeUtils.isPrimitiveType def.type
            acc.push prefix.concat(field).join '_'
        else
            if typeUtils.isCustomType def.type
                prefix.push field
                getMappableFields def.ctor, acc, prefix
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
        if yield @parser.body('meta')
            post = yield post.addMetaList (yield @parser.body 'meta').split(',')
        this.body = post
    else
        this.body = 'INVALID_POST'

