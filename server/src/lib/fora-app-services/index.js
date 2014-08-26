(function() {

    var services = {};

    var typeHelpers = require('fora-app-type-helpers');

    var add = function(name, obj) {
        services[name] = obj;
    };

    var get = function(name) {
        return services[name];
    };

    var context = function(params) {
        var clone = typeHelpers.clone(services);
        if (params) {
            for (var key in params) {
                clone[key] = params[key];
            }
        }
        return clone;
    };

    module.exports = {
        add: add,
        get: get,
        context: context
    };

})();
