(function() {
    "use strict";

    /* Routing */
    var auth = require('./auth');
    var users = require('./users');
    var apps = require("./apps");

    exports.init = function*() {
        //home
        this.routes.get("", home.index);

        //login
        this.routes.get("auth/twitter", auth.twitter);
        this.routes.get("auth/twitter/callback", auth.twitterCallback);

        //users
        this.routes.get("users/login", users.login);
        this.routes.get("~:username", users.item);

        //apps
        this.routes.get("apps", apps.index);
        this.routes.get("apps/new", apps.create);
    };
})();
