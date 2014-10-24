(function() {
    "use strict";

    module.exports = function(api) {
        var config = api.get("configuration");
        
        return {
            routes: [
                { method: "get", url: "", handler: require('./views/home/index') },
                { method: "get", url: "/" + config.typeAliases.app.plural, handler: require('./views/apps/index') }
            ]
        };
    };

})();
