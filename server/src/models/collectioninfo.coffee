ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

            
class CollectionInfo extends ForaDbModel
    @typeDefinition: {
        type: @,
        alias: 'CollectionInfo',
        collection: 'collectioninfo',
        fields: {
            collectionid: 'string',
            about: 'string !required',
            message: 'string !required'
        }
    }
    
    
exports.CollectionInfo = CollectionInfo    
