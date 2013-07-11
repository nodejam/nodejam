AppError = require('../common/apperror').AppError
conf = require '../conf'
models = require './'
BaseModel = require('./basemodel').BaseModel

class Network extends BaseModel

    @_getMeta: ->
        User = require('./user').User
        {
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
                                if ['facebook', 'twitter', 'users'].indexOf type.name is -1 
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
                    contents: User.Summary,
                    validate: ->                    
                        if not @admins.length
                            errors.push 'admins are missing.'                        
                        else
                            admin.validate() for admin in @admins
                }
            }
            logging: {
                isLogged: true,
            }
        }
        

exports.Network = Network
