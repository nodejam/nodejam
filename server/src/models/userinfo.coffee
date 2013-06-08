BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class UserInfo extends BaseModel

    ###
        Fields
            - network (string)        
            - userid (string)         
            - subscriptions (list of collection summary)   
            - following (list of user summary)
            - lastMessageAccessTime (integer)
    ###    
        
    @_meta: {
        type: UserInfo,
        collection: 'userinfo',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },
        logging: {
            isLogged: false,
            onInsert: 'NEW_USERINFO'
        }
    }
    
    
    constructor: (params) ->
        @subscriptions ?= []
        @following ?= []
        super
        


    save: (context, cb) =>
        super



    validate: =>
        errors = super().errors

        if not @network or typeof @network isnt 'string'
            errors.push 'Invalid network.'      
                    
        if not @userid
            errors.push 'Missing userid.'

        if not @subscriptions
            errors.push 'Missing subscriptions.'
        

        for coll in @subscriptions
            _errors = UserInfo._models.Collection.validateSummary(coll)
            if _errors.length
                errors.push 'Invalid subscription.'
                errors = errors.concat _errors

        if not @following
            errors.push 'Missing following.'

        for user in @following
            _errors = UserInfo._models.User.validateSummary(user)
            if _errors.length
                errors.push 'Invalid followed.'
                errors = errors.concat _errors
        
        { isValid: errors.length is 0, errors }
    
    
    
exports.UserInfo = UserInfo
