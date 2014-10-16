(function() {
    "use strict";

    module.exports = {
        routes: [
            { method: "get", url: "", handler: require('./views/home/index') },
            { method: "get", url: "", handler: require('./views/apps/index') }
        ]
    };

})();
