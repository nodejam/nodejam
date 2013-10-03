ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

            
class CollectionInfo extends ForaDbModel
    @describeType: {
        type: @,
        collection: 'collectioninfo',
        fields: {
            collectionid: 'string',
            about: { type: 'string', required: false },
            message: { type: 'string', required: false }
        }
    }
    
    
exports.CollectionInfo = CollectionInfo    
