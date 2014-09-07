(function() {
    "use strict";

    var credentials = require('./credentials'),
        users = require('./users'),
        apps = require("./apps"),
        images = require("./images");

    var ui_home = require('./ui/home');

    module.exports = [

        //credentials
        { method: "post", url: "/api/credentials", handler: credentials.create },

        //users
        { method: "post", url: "/api/users", handler: users.create },
        { method: "post", url: "/api/login", handler: users.login },
        { method: "get", url: "/api/users/:username", handler: users.item },

        //apps
        { method: "post", url: "/api/apps", handler: apps.create },

        //images
        { method: "post", url: "/api/images", handler: images.upload },

        //ui_home
        { method: "get", url: "/api/ui/home", handler: ui_home.index }

    ];
})();
