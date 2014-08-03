(function() {
    "use strict";

    /* Routing */
    var members = require('./members');
    var records = require('./records');

    exports.init = function*() {
        this.routes.post("members", members.join);
        this.routes.post("", records.create);
        this.routes.put("records/:record", records.edit);
        this.routes.put("admin/records/:record", records.admin_update);
    };

})();
