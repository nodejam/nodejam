conf = require '../conf'
DatabaseAppModel = require('./appmodels').DatabaseAppModel

class Network extends DatabaseAppModel

    @describeModel: ->
        {
            type: @,
            collection: 'networks',
            fields: {
                name: 'string',
                stub: 'string',
                domains: { type: 'array', contents: 'string' },
                templates: 'any',
                defaultTemplates: 'any'
            }
        }



    getLayout: (name) =>
        name = name ? 'default'
        @templates.layouts?[name] ? @defaultTemplates.layouts[name]

        
        
    getView: (controller, view) =>
        @templates.views?[controller]?[view] ? @defaultTemplates.views[controller][view]
            

exports.Network = Network
