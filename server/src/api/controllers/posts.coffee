conf = require '../../conf'
db = require('../app').db
models = require '../../models'
typeUtils = require('../../models/foratypeutils').typeUtils
utils = require '../../lib/utils'
auth = require '../../common/web/auth'


exports.create = auth.handler { session: true }, (forum) ->*
    query = db.setRowId { network: @network.stub }, forum
    forum = yield models.Forum.get query, { user: @session.user }, db

    post = yield models.Post.create {
        type: yield @parser.body('type'),
        createdById: @session.user.id,
        createdBy: @session.user,
        state: yield @parser.body('state'),
        rating: 0,
        savedAt: Date.now()
    }
    
    yield @parser.map post, yield getMappableFields yield post.getTypeDefinition()
    post = yield forum.addPost post
    this.body = post



exports.edit = auth.handler { session: true }, (forum, post) ->*
    query = db.setRowId { network: @network.stub }, forum
    forum = yield models.Forum.get query, { user: @session.user }, db

    post = yield models.Post.getById post, { user: @session.user }, db
    
    if post
        if (post.createdBy.username is @session.user.username) 
            post.savedAt = Date.now()                       
            yield @parser.map post, yield getMappableFields yield post.getTypeDefinition()
            if yield @parser.body('state') is 'published'
                post.state = 'published'
            post = yield post.save()
            this.body = post
        else
            this.body = 'Access denied'
    else
        this.body = 'Access denied'



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
            this.body = 'Access denied'
    else
        this.body = 'Invalid Post'
                 

        
#Admin Features
exports.admin_update = auth.handler { admin: true }, (id) ->*
    post = yield models.Post.getById(id, { user: @session.user }, db)
    if post 
        meta = yield @parser.body('meta')
        if meta
            post = yield post.addMetaList meta.split(',')
        this.body = post
    else
        this.body = 'Invalid Post'

