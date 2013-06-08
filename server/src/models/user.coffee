utils = require '../common/utils'

BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class User extends BaseModel

    ###
        Fields
            - network (string)
            - domain (string; 'fb' or 'poets')
            - domainid (string)
            - username (string)
            - domainidType (string; 'username' or 'domainid')
            - name (string)
            - location (string)
            - picture (string)
            - thumbnail (string)
            - email (string)
            - accessToken (string)
            - lastLogin (integer)
            - followers (array of summarized user)
            - following (array of summarized user)
            - about (string)
            - karma (integer)
            - facebookUsername (string)
            - twitterUsername (string)
            - website (string)
    ###            
    
    @_meta: {
        type: User,
        collection: 'users',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
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
        


    validate: =>
        errors = super().errors
        
        if not @network or typeof @network isnt 'string'
            errors.push "Invalid network."
        
        if @domain isnt 'fb' and @domain isnt 'users' and @domain isnt 'tw'
            errors.push 'Invalid domain.'
        
        if not @domainid or not @username
            errors.push 'Invalid domainid.'
        
        if @domainidType isnt 'username' and @domainidType isnt 'domainid'
            errors.push 'Invalid domainidType.'
        
        if not @name 
            errors.push 'Invalid name.'
            
        if not @preferences
            errors.push 'Invalid preferences.'

        if isNaN(@lastLogin)            
            errors.push 'Invalid lastLogin.'

        { isValid: errors.length is 0, errors }
    

exports.User = User
