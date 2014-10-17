(function() {

    "use strict";

    var members = require('./members'),
        records = require('./records');

    var config = require('fora-app-services').get('configuration');

    module.exports = {
        routes: [
            { method: "post", url: "/members", handler: members.join },
            { method: "post", url: "/", handler: records.create },
            { method: "post", url: "/" + config.typeAliases.record.plural, handler: records.create },
            { method: "put", url: "/" + config.typeAliases.record.plural + "/:record", handler: records.edit },
            { method: "put", url: "/admin/" + config.typeAliases.record.plural + "/:record", handler: records.admin_update }
        ]
    };

})();
