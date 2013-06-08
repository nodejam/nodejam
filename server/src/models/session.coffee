BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class Session extends BaseModel

    ###
        Fields
            - network (string)        
            - passkey (string)
            - accessToken (string)
            - userid (string)
    ###    
    
    @_meta: {
        type: Session,
        collection: 'sessions',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },
        logging: {
            isLogged: false
        }
    }    



    validate: =>
        errors = super().errors

        if not @network or typeof @network isnt 'string'
            errors.push 'Invalid network.'
        
        if not @passkey
            errors.push 'Invalid passkey.'

        if not @accessToken
            errors.push 'Invalid accessToken.'
            
        if not @userid
            errors.push 'Invalid userid.'
            
        { isValid: errors.length is 0, errors }



exports.Session = Session
