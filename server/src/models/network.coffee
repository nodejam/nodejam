ForaDbModel = require('./foramodel').ForaDbModel
models = require('./')

class Network extends ForaDbModel

    @typeDefinition: {
        type: @,
        alias: "Network",
        collection: 'networks',
        fields: {
            name: 'string',
            stub: 'string',
            domains: { type: 'array', contents: 'string' },
        },
        logging: {
            onInsert: 'NEW_USER'
        }
    }


    constructor: (params) ->
        @templates = {}
        super
            

exports.Network = Network
