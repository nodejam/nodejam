ForaDbModel = require('./foramodel').ForaDbModel
models = require('./')

class Token extends ForaDbModel

    @typeDefinition: {
        name: "token",
        collection: 'tokens',
        schema: {
            type: 'object',        
            properties: {
                type: { type: 'string' },
                key: { type: 'string' },
                value: { 
                    type: 'object'
                },
            }
            required: ['type', 'key', 'value']
        },
        indexes: [{ 'key': 1 }],
    }
    
    
module.exports = Token
