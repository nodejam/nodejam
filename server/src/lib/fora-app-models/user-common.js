(function() {
    "use strict";

    var services = require('fora-app-services'),
        DbConnector = require('fora-app-db-connector');

    var UserSummary = require('./user-summary').UserSummary;

    var extendUser = function(User) {
        User.typeDefinition = {
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
        };


        User.prototype.getUrl = function() {
            return "/~" + this.username;
        };

        User.prototype.getAssetUrl = function() {
            return "/public/assets/" + this.assets;
        };

        User.prototype.summarize = function*() {
            var typesService = services.get('typesService');
            return yield* typesService.constructModel(
                {
                    id: DbConnector.getRowId(this),
                    username: this.username,
                    name: this.name,
                    assets: this.assets
                },
                UserSummary
            );
        };
    };

    exports.extendUser = extendUser;

})();
