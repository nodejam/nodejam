BaseModel = require('./basemodel').BaseModel
AppError = require('../common/apperror').AppError
conf = require '../conf'

class Network extends BaseModel

    ###
        Fields
            - name
            - stub
            - authenticationTypes (list of { name:string, params:depends on name })
            - item types (list of string)
            - admins
    ###    
        
    @_meta: {
        type: Network,
        collection: 'networks',
        logging: {
            isLogged: true,
        }
    }
    

    validate: =>
        errors = super().errors
        
        if not @name
            errors.push 'Network name is missing.'
            
        if not @stub
            errors.push 'Stub is missing.'            
                
        if not @authenticationTypes or not @authenticationTypes.length
            errors.push 'Authentication Types are missing.'
        else
            for type in @authenticationTypes
                if ['facebook', 'twitter', 'fora'].indexOf type.name is -1 
                    errors.push "#{type.name} is not a valid Authentication Type."
                if type.name is 'twitter'
                    if not type.params
                        errors.push "Twitter authentication parameters are missing."
                    else
                        if not type.params.TWITTER_CONSUMER_KEY
                            errors.push "Twitter consumer key is missing."
                        if not type.params.TWITTER_SECRET
                            errors.push "Twitter consumer secret is missing."
                        if not type.params.TWITTER_CALLBACK
                            errors.push "Twitter callback is missing."
        
        if not @admins or not @admins.length
            errors.push 'Admins are missing.'
        else
            for admin in @admins                        
                _errors = Network._models.User.validateSummary(admin)
                if _errors.length
                    errors.push 'Invalid admin.'
                    errors = errors.concat _errors
        
        { isValid: errors.length is 0, errors }
    
    
    
exports.Network = Network
