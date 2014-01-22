ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

            
class ForumInfo extends ForaDbModel
    @typeDefinition: {
        name: 'forum-info',
        collection: 'foruminfo',
        schema: {
            type: 'object',        
            properties: {
                forumid: { type: 'string' },
                about: { type: 'string' },
                message: { type: 'string' }
            },
            required: ['forumid']
        }
    }
    
    
exports.ForumInfo = ForumInfo    
