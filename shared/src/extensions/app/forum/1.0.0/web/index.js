(function() {
    "use strict";

    var router;

    var init = function*() {
        router = configureRouter();
        return;
        yield false;
    };

    var configureRouter = function() {
        var home = require('./home');

        var Router = require("fora-router");
        var router = new Router();

        router.get("/", home.index);

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
