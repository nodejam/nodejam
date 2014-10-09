(function() {
    "use strict";

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var services = require('fora-app-services');
    var ForaModel = require('./foramodel').ForaModel;
    var ForaDbModel = require('./foramodel').ForaDbModel;

    var UserBase = function() {
        ForaDbModel.apply(this, arguments);
    };

    UserBase.prototype = Object.create(ForaDbModel.prototype);
    UserBase.prototype.constructor = UserBase;

    __extends(UserBase, ForaDbModel);


    //Settings
    var UserSummary = function() {
        ForaModel.apply(this, arguments);
    };

    UserSummary.prototype = Object.create(ForaModel.prototype);
    UserSummary.prototype.constructor = UserSummary;

    __extends(UserSummary, ForaModel);

    UserSummary.typeDefinition = {
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
    };

    UserSummary.prototype.getUrl = function() {
        return "/~" + this.username;
    };

    UserSummary.prototype.getAssetUrl = function() {
        return "/public/assets/" + this.assets;
    };

    UserBase.typeDefinition = {
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


    UserBase.prototype.getUrl = function() {
        return "/~" + this.username;
    };

    UserBase.prototype.getAssetUrl = function() {
        return "/public/assets/" + this.assets;
    };

    UserBase.prototype.summarize = function*() {
        var typesService = services.get('typesService');
        return yield* typesService.constructModel(
            {
                id: services.get('db').getRowId(this),
                username: this.username,
                name: this.name,
                assets: this.assets
            },
            UserSummary
        );
    };

    exports.UserBase = UserBase;
    exports.UserSummary = UserSummary;

})();
