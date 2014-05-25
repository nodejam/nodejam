ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

            
class ForumInfo extends ForaDbModel
    @typeDefinition: {
        name: 'forum-info',
        collection: 'foruminfo',
        schema: {
            type: 'object',        
            properties: {
                forumId: { type: 'string' },
                about: { type: 'string' },
                message: { type: 'string' }
            },
            required: ['forumId']
        },
        links: {
            forum: { type: 'forum', key: 'forumId' }
        }
    }
    
    
exports.ForumInfo = ForumInfo    
