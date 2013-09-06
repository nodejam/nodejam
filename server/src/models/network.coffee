conf = require '../conf'
DatabaseModel = require('../common/data/databasemodel').DatabaseModel
models = require('./')

class Network extends DatabaseModel

    @describeModel: {
        type: @,
        collection: 'networks',
        fields: {
            name: 'string',
            stub: 'string',
            domains: { type: 'array', contentType: 'string' },
            templates: 'any',
            defaultTemplates: 'any'
        },
        logging: {
            onInsert: 'NEW_USER'
        }
    }



    getLayout: (name) =>
        name = name ? 'default'
        @templates.layouts?[name] ? @defaultTemplates.layouts[name]

        
        
    getView: (controller, view) =>
        @templates.views?[controller]?[view] ? @defaultTemplates.views[controller][view]
            

exports.Network = Network
