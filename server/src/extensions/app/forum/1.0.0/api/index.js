(function() {

    "use strict";

    var members = require('./members'),
        records = require('./records');

    module.exports = {
        routes: [
            { method: "post", url: "/members", handler: members.join },
            { method: "post", url: "/", handler: records.create },
            { method: "post", url: "/records", handler: records.create },
            { method: "put", url: "/records/:record", handler: records.edit },
            { method: "put", url: "/admin/records/:record", handler: records.admin_update }
        ]
    };

})();
