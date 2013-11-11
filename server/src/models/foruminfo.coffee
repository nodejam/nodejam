ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

            
class ForumInfo extends ForaDbModel
    @typeDefinition: {
        type: @,
        alias: 'ForumInfo',
        collection: 'foruminfo',
        fields: {
            forumid: 'string',
            about: 'string !required',
            message: 'string !required'
        }
    }
    
    
exports.ForumInfo = ForumInfo    
