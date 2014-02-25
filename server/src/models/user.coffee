thunkify = require 'thunkify'
ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel
utils = require '../lib/utils'
hasher = require('../lib/hasher')
models = require './'
conf = require '../conf'


class User extends ForaDbModel

    class Summary extends ForaModel    
        @typeDefinition: {
            name: "user-summary",
            schema: {
                type: 'object',        
                properties: {
                    id: { type: 'string' },
                    username: { type: 'string' },
                    name: { type: 'string' },
                    assets: { type: 'string' }
                },
                required: ['id', 'username', 'name', 'assets']
            }
        }
        
    @Summary: Summary
    
    @childModels: { Summary }

    @typeDefinition: {
        name: "user",
        collection: 'users',
        schema: {
            type: 'object',      
            properties: {
                credentialId: { type: 'string' },
                token: { type: 'string' },
                username: { type: 'string' },
                name: { type: 'string' },
                assets: { type: 'string' },
                location: { type: 'string' },
                followingCount: { type: 'integer' }, 
                followerCount: { type: 'integer' },
                lastLogin: { type: 'number' },
                about: { type: 'string' }
            },
            required: ['credentialId', 'token', 'username', 'name', 'assets', 'followingCount', 'followerCount', 'lastLogin']
        },
        indexes: [
            { 'credentialId': 1 },
            { 'token': 1 },
            { 'userId': 1 },
            { 'username': 1 }
        ],
        links: {
            info: { type: 'user-info', field: 'userId', multiplicity: 'one' }
        }
    }
       

   
    save: (context, db) =>*
        if not @_id
            existing = yield User.get { @username }, context, db
            if not existing
                @token = utils.uniqueId(24)
                @lastLogin = 0
                @followingCount = 0
                @followerCount = 0
            else
                throw new Error "User(#{@username}) already exists"
        else
            super
    
        required: ['credentialId', 'token', 'username', 'name', 'assets', 'followingCount', 'followerCount', 'lastLogin']


                                                            
    getPosts:(limit, sort, context, db) =>*
        { context, db } = @getContext context, db
        yield models.Post.find({ 'createdById': @_id.toString(), state: 'published' }, ((cursor) -> cursor.sort(sort).limit limit), context, db)
    
    
    
    getUrl: =>
        "/~#{@username}"



    getAssetUrl: =>
        "/public/assets/#{@assets}"



    summarize: =>
        new Summary {
            id: @_id.toString(),
            @username,
            @name,
            @assets
        }
        
    
exports.User = User
