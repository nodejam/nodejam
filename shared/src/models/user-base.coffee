ForaModel = require('./foramodel').ForaModel
ForaDbModel = require('./foramodel').ForaDbModel

class UserBase extends ForaDbModel

    class Summary extends ForaModel    
        @typeDefinition: {
            name: "user-summary",
            schema: {
                type: 'object',        
                properties: {
                    id: { type: 'string' },
                    username: { type: 'string' },
                    name: { type: 'string' },
                    assets: { type: 'string' }
                },
                required: ['id', 'username', 'name', 'assets']
            }
        }
        
        getUrl: =>
            "/~#{@username}"


        getAssetUrl: =>
            "/public/assets/#{@assets}"
        
        
    @Summary: Summary
    
    @childModels: { Summary }

    @typeDefinition: {
        name: "user",
        collection: 'users',
        schema: {
            type: 'object',      
            properties: {
                credentialId: { type: 'string' },
                username: { type: 'string' },
                name: { type: 'string' },
                assets: { type: 'string' },
                location: { type: 'string' },
                followingCount: { type: 'integer' }, 
                followerCount: { type: 'integer' },
                lastLogin: { type: 'number' },
                about: { type: 'string' }
            },
            required: ['credentialId', 'username', 'name', 'assets', 'followingCount', 'followerCount', 'lastLogin']
        },
        indexes: [
            { 'credentialId': 1 },
            { 'token': 1 },
            { 'userId': 1 },
            { 'username': 1 }
        ],
        links: {
            credential: { type: 'credential', key: 'credentialId' },
            info: { type: 'user-info', field: 'userId', multiplicity: 'one' }
        }
    }
    
    
    getUrl: =>
        "/~#{@username}"



    getAssetUrl: =>
        "/public/assets/#{@assets}"



    summarize: (context, db) =>
        new User.Summary {
            id: db.getRowId(@),
            @username,
            @name,
            @assets
        }    
       
    
exports.UserBase = UserBase
