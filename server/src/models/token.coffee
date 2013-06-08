BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError

class Token extends BaseModel

    ###
        Fields
            - network (string)        
            - type (string)            
            - key (string)
            - value (string)
    ###    
        
    @_meta: {
        type: Token,
        collection: 'tokens',
        autoInsertedFields: {
            created: 'createdAt',
            updated: 'timestamp'
        },
        logging: {
            isLogged: false,
        }
    }
    

    validate: =>
        errors = super().errors

        if not @network or typeof @network isnt 'string'
            errors.push 'Invalid network.'      
                    
        if not @type
            errors.push 'Invalid type.'

        if not @key
            errors.push 'Invalid key.'

        if not @value
            errors.push 'Invalid value.'
        
        { isValid: errors.length is 0, errors }
    
    
    
exports.Token = Token
