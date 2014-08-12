(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var ForaDbModel = require('./foramodel').ForaDbModel;


    var AppInfo = function() {
        ForaDbModel.apply(this, arguments);
    };

    AppInfo.prototype = Object.create(ForaDbModel.prototype);
    AppInfo.prototype.constructor = AppInfo;

    __extends(AppInfo, ForaDbModel);


    AppInfo.typeDefinition = {
        name: 'app-info',
        collection: 'appinfo',
        schema: {
            type: 'object',
            properties: {
                appId: { type: 'string' },
                about: { type: 'string' },
                message: { type: 'string' }
            },
            required: ['appId']
        },
        links: {
            app: { type: 'app', key: 'appId' }
        }
    };

    exports.AppInfo = AppInfo;

})();
