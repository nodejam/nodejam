(function() {
    "use strict";

    var services = require("fora-lib-services");
    var config = services.getConfiguration();

    module.exports =  {
        routes: [
            { method: "get", url: "", handler: require('./views/home/index') },
            { method: "get", url: "/" + config.typeAliases.app.plural, handler: require('./views/apps/index') }
        ]
    };

})();
