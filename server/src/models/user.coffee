utils = require '../common/utils'
Models = require './'
AppError = require('../common/apperror').AppError
BaseModel = require('./basemodel').BaseModel

class User extends BaseModel

    @_meta: {
        type: User,
        collection: 'users',
        fields: {
            network: 'string',
            domain: { type: 'string', validate: -> ['twitter', 'fb', 'fora'].indexOf(@domain) is -1 },
            domainid: 'string',
            username: 'string',
            domainidType: { type: 'string', validate: -> ['username', 'domainid'].indexOf(@domainidType) is -1 },
            name: 'string',
            location: 'string',
            picture: 'string',
            thumbnail: 'string',
            email: 'string',
            accessToken: 'string',
            lastLogin: 'string',
            followers: { type: 'array', contents: User.Summary, validate: -> user.validate() for user in @followers },
            following: { type: 'array', contents: User.Summary, validate: -> user.validate() for user in @following },
            about: 'string',
            createdAt: { autoGenerated: true, event: 'created' },
            updatedAt: { autoGenerated: true, event: 'updated' }            
        },
        logging: {
            isLogged: true,
            onInsert: 'NEW_USER'
        }
    }
    
    
    #Called from controllers when a new session is created.
    @getOrCreateUser: (userDetails, domain, network, accessToken, cb) =>
        @_models.Session.get { accessToken, network }, {}, (err, session) =>
            if err
                cb err
            else
                session ?= new @_models.Session { passkey: utils.uniqueId(24), accessToken }
                    
                User.get { domain, username: userDetails.username, network: network }, {}, (err, user) =>
                    if user?
                        #Update some details
                        user.name = userDetails.name ? user.name
                        user.domainid = userDetails.domainid ? user.domainid
                        user.network = userDetails.network ? user.network
                        user.username = userDetails.username ? userDetails.domainid
                        user.domainidType = if userDetails.username then 'username' else 'domainid'
                        user.location = userDetails.location ? user.location
                        user.picture = userDetails.picture ? user.picture
                        user.thumbnail = userDetails.thumbnail ? user.thumbnail
                        user.tile = userDetails.tile ? user.tile
                        user.email = userDetails.email ? 'unknown@poe3.com'
                        user.lastLogin = Date.now()
                        user.save {}, (err, u) =>
                            if not err
                                session.userid = u._id.toString()
                                session.network = network
                                session.save {}, (err, session) =>
                                    if not err
                                        cb null, u, session
                                    else
                                        cb err
                            else
                                cb err
                        
                    else                            
                        #User doesn't exist. create.
                        user = new User()
                        user.domain = domain
                        user.network = network
                        user.domainid = userDetails.domainid
                        user.username = userDetails.username ? userDetails.domainid
                        user.domainidType = if userDetails.username then 'username' else 'domainid'
                        if domain is 'fb'
                            user.facebookUsername = userDetails.username
                        if domain is 'tw'
                            user.twitterUsername = userDetails.username
                        user.name = userDetails.name
                        user.location = userDetails.location
                        user.picture = userDetails.picture
                        user.thumbnail = userDetails.thumbnail
                        user.tile = userDetails.tile ? '/images/collection-tile.png'
                        user.email = userDetails.email ? 'unknown@poe3.com'
                        user.lastLogin = Date.now()
                        user.preferences = { canEmail: true }
                        user.createdAt = Date.now()
                        user.save {}, (err, u) =>
                            #also create the userinfo
                            if not err
                                userinfo = new @_models.UserInfo()
                                userinfo.userid = u._id.toString()
                                userinfo.network = network
                                userinfo.save {}, (err, _uinfo) =>
                                    if not err
                                        session.network = network
                                        session.userid = u._id.toString()
                                        session.save {}, (err, session) =>
                                            if not err
                                                cb null, u, session
                                            else
                                                cb err
                                    else
                                        cb err
                            else
                                cb err
                                
    
    
    @getById: (id, context, cb) ->
        super id, context, cb

    

    @getByUsername: (domain, username, context, cb) ->
        User.get { domain, username }, context, (err, user) ->
            cb null, user


    
    @validateSummary: (user) =>
        errors = []
        if not user
            errors.push "Invalid user."
        
        required = ['id', 'domain', 'username', 'name']
        for field in required
            if not user[field]
                errors.push "Invalid #{field}"
                
        errors
        
        

    constructor: (params) ->
        @about ?= ''
        @karma ?= 1
        @preferences ?= {}
        @totalItemCount = 0
        super

        

    getUrl: =>
        if @domain is 'tw' then "/@#{@username}" else "/#{@domain}/#{@username}"



    save: (context, cb) =>
        super


    summarize: (fields = []) =>
        fields = fields.concat ['domain', 'username', 'name', 'network']
        result = super fields
        result.id = @_id.toString()
        result

    

exports.User = User
