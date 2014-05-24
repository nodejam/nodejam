thunkify = require 'thunkify'
ForaDbModel = require('./foramodel').ForaDbModel
models = require('./')

###
    A session token starts life as a credential token.
    A credential token can be converted into a user-session token.
###
class Session extends ForaDbModel
    
    @typeDefinition: {
        name: 'session',
        collection: 'sessions',
        schema: {
            type: 'object',        
            properties: {
                credentialId: { type: 'string' }
                userId: { type: 'string' },
                token: { type: 'string' },
                user: { $ref: 'user-summary' }
            },
            required: ['credentialId', 'token']
        },
        links: {
            credential: { key: 'credentialId' },
        }
        autoGenerated: {
            createdAt: { event: 'created' },
            updatedAt: { event: 'updated' }
        },
        indexes: [
            { 'userId': 1, 'token': 1 },
        ]
    }
    


    #Upgrades a credential token to a user token. 
    #User tokens can be used to login to the app.
    upgrade: (username, context, db) =>*
        { context, db } = @getContext context, db
        user = yield models.User.get { username, credentialId: @credentialId }, context, db
        if user
            @token = utils.uniqueId(24) 
            @userId = user._id.toString()
            @user = user.summarize context, db
            yield @save context, db
        else
            throw new Error "User not found"


    
    
module.exports = Session
