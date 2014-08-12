(function() {
    "use strict";

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var ForaModel = require('./foramodel').ForaModel;
    var ForaDbModel = require('./foramodel').ForaDbModel;

    var UserBase = function() {
        ForaDbModel.apply(this, arguments);
    };

    UserBase.prototype = Object.create(ForaDbModel.prototype);
    UserBase.prototype.constructor = UserBase;

    __extends(UserBase, ForaDbModel);


    //Settings
    var Summary = function() {
        ForaModel.apply(this, arguments);
    };

    Summary.prototype = Object.create(ForaModel.prototype);
    Summary.prototype.constructor = Summary;

    __extends(Summary, ForaModel);

    Summary.typeDefinition = {
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

    Summary.prototype.getUrl = function() {
        return "/~" + this.username;
    };

    Summary.prototype.getAssetUrl = function() {
        return "/public/assets/" + this.assets;
    };

    UserBase.Summary = Summary;

    UserBase.childModels = { Summary: Summary };

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

    UserBase.prototype.summarize = function(context) {
        return new UserBase.Summary({
            id: context.db.getRowId(this),
            username: this.username,
            name: this.name,
            assets: this.assets
        });
    };

    exports.UserBase = UserBase;

})();
