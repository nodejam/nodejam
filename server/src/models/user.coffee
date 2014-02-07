thunkify = require 'thunkify'
ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel
utils = require '../lib/utils'
hasher = require('../lib/hasher')
models = require './'
conf = require '../conf'
emailRegex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

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
                required: ['id', 'username', 'name']
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
                username: { type: 'string' },
                name: { type: 'string' },
                assets: { type: 'string' },
                location: { type: 'string' },
                followerCount: { type: 'integer' },
                email: { type: 'string' },
                lastLogin: { type: 'number' }
                about: { type: 'string' },
            },
            required: ['username', 'name', 'assets', 'followerCount', 'email', 'lastLogin']
        }
        validate: ->*
            if not emailRegex.test(@email)
                ['Invalid email']            
        logging: {
            onInsert: 'NEW_USER'
        }
    }
       

   
    create: (authInfo, context, db) =>*
        #We can't create a new user with an existing username.
        if not @_id and not (yield User.get { @username }, context, db)
            @preferences = { canEmail: true }

            @assets = "#{utils.getHashCode(@username) % conf.userDirCount}"
            user = yield @save context, db
            
            #Also create a userinfo
            userinfo = new (models.UserInfo) {
                userid: @_id.toString(),
            }
            userinfo = yield userinfo.save context, db

            credentials = new (models.Credentials) {
                userid: user._id.toString(),
                @username,
                token: utils.uniqueId(24)                    
            }

            switch authInfo.type
                when 'builtin'
                    result = yield thunkify(hasher) { plaintext: authInfo.value.password }
                    salt = result.salt.toString 'hex'
                    hash = result.key.toString 'hex'
                    credentials.builtin = { method: 'PBKDF2', @username, hash, salt }
                when 'twitter'
                    credentials.twitter = authInfo.value
            
            credentials = yield credentials.save context, db
                    
            { user, token: credentials.token }
        else
            { success: false, error: "User aready exists" }
            

                                                            
    @getByUsername: (username, context, db) ->
        User.get({ username }, context, db)



    constructor: (params) ->
        @followerCount ?= 0
        super



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
