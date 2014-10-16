(function() {
    "use strict";

    var credentials = require('./credentials'),
        users = require('./users'),
        apps = require("./apps"),
        images = require("./images");

    var ui_home = require('./ui/home');

    module.exports = {
        routes: [
            //credentials
            { method: "post", url: "/credentials", handler: credentials.create },

            //users
            { method: "post", url: "/users", handler: users.create },
            { method: "post", url: "/login", handler: users.login },
            { method: "get", url: "/users/:username", handler: users.item },

            //apps
            { method: "post", url: "/apps", handler: apps.create },

            //images
            { method: "post", url: "/images", handler: images.upload },

            //ui_home
            { method: "get", url: "/ui/home", handler: ui_home.index }
        ]
    };
    
})();
