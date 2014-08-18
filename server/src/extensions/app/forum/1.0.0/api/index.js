(function() {
    "use strict";

    var router;

    var init = function*() {
        router = configureRouter();
    };

    var configureRouter = function() {
        var members = require('./members'),
            records = require('./records');

        var Router = require("fora-router");
        var router = new Router();

        router.post("/members", members.join);
        router.post("/", records.create);
        router.post("/records", records.create);
        router.put("/records/:record", records.edit);
        router.put("/admin/records/:record", records.admin_update);

        return router;
    };

    var getRouter = function*() {
        return router;
    };

    module.exports = {
        init: init,
        getRouter: getRouter
    };

})();
