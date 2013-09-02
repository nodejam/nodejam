conf = require '../conf'
BaseModel = require('./basemodel').BaseModel

class Network extends BaseModel

    @describeModel: ->
        {
            type: Network,
            collection: 'networks',
            fields: {
                name: 'string',
                stub: 'string',
                domains: { type: 'array', contents: 'string' },
                templates: 'any',
                defaultTemplates: 'any'
            }
            logging: {
                isLogged: true,
            }
        }



    getLayout: (name) =>
        name = name ? 'default'
        @templates.layouts?[name] ? @defaultTemplates.layouts[name]

        
        
    getView: (controller, view) =>
        @templates.views?[controller]?[view] ? @defaultTemplates.views[controller][view]
            

exports.Network = Network
