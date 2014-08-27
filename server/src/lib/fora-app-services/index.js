(function() {

    var services = function() {
        return services;
    };

    var typeHelpers = require('fora-app-type-helpers');

    services.add = function(name, obj) {
        services[name] = obj;
    };

    services.get = function(name) {
        return services[name];
    };

    services.copy = function(params) {
        var clone = typeHelpers.clone(services);
        if (params) {
            for (var key in params) {
                clone[key] = params[key];
            }
        }
        return clone;
    };

    module.exports = services;

})();
