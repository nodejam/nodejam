(function() {
    "use strict";

    var services = require("fora-app-services");
    var config = services.get("configuration");

    module.exports =  {
        routes: [
            { method: "get", url: "", handler: require('./views/home/index') },
            { method: "get", url: "/" + config.typeAliases.app.plural, handler: require('./views/apps/index') }
        ]
    };

})();
