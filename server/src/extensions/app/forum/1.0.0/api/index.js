(function() {

    "use strict";

    var members = require('./members'),
        records = require('./records');

    var config = require('fora-app-services').get('configuration');

    module.exports = function() {
        return {
            routes: [
                { method: "post", url: "/members", handler: members.join },
                { method: "post", url: "/", handler: records.create },
                { method: "post", url: "/posts", handler: records.create },
                { method: "put", url: "/posts/:post", handler: records.edit },
                { method: "put", url: "/admin/posts/:post", handler: records.admin_update }
            ]
        };
    };

})();
