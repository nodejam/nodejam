ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

            
class AppInfo extends ForaDbModel
    @typeDefinition: {
        name: 'app-info',
        collection: 'appinfo',
        schema: {
            type: 'object',        
            properties: {
                appId: { type: 'string' },
                about: { type: 'string' },
                message: { type: 'string' }
            },
            required: ['appId']
        },
        links: {
            app: { type: 'app', key: 'appId' }
        }
    }
    
    
exports.AppInfo = AppInfo    
