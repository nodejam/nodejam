(function() {
    "use strict";

    var credentials = require('./credentials'),
        users = require('./users'),
        apps = require("./apps"),
        images = require("./images");

    var ui_home = require('./ui/home'),
        ui_apps = require('./ui/apps');

    var services = require("fora-app-services");
    var config = services.get("configuration");

    module.exports =  {
        routes: [
            //credentials
            { method: "post", url: "/credentials", handler: credentials.create },

            //users
            { method: "post", url: "/users", handler: users.create },
            { method: "post", url: "/login", handler: users.login },
            { method: "get", url: "/users/:username", handler: users.item },

            //apps
            { method: "post", url: "/" + config.typeAliases.app.plural, handler: apps.create },

            //images
            { method: "post", url: "/images", handler: images.upload },

            //ui_home
            { method: "get", url: "/ui/home", handler: ui_home.index },

            //ui_apps
            { method: "get", url: "/ui/apps", handler: ui_apps.index }
        ]
    };

})();
