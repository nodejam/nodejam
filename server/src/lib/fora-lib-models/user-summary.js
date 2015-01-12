(function() {

    "use strict";

    var dataUtils = require('fora-data-utils');

    var UserSummary = function(params) {
        dataUtils.extend(this, params);
    };

    UserSummary.entitySchema = {
        schema: {
            id: "user-summary",
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

    exports.UserSummary = UserSummary;

})();
