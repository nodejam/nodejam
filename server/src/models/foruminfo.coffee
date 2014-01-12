ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

            
class ForumInfo extends ForaDbModel
    @typeDefinition: {
        type: @,
        name: 'forum-info',
        collection: 'foruminfo',
        fields: {
            forumid: 'string',
            about: 'string !required',
            message: 'string !required'
        }
    }
    
    
exports.ForumInfo = ForumInfo    
