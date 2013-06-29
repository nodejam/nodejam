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
        fields: {
            name: 'string',
            stub: 'string',
            authenticationTypes: { 
                type: 'array', 
                contents: 'object', 
                validate: ->
                    if not @authenticationTypes.length
                        'Authentication types not defined.'
                    else
                        errors = []
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
                        errors
                        
            },
            admins: {
                type: 'array',
                contents: 'object',
                validate: ->
                    if not @admins.length
                        errors.push 'Admins are missing.'                        
                    else
                        errors = []
                        for admin in @admins
                            errors.concat admin.validate()
                        errors
            }
        }
        logging: {
            isLogged: true,
        }
    }
    

exports.Network = Network
