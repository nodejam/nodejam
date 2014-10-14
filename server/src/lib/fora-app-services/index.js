(function() {

    var _store = {};

    var services ={};

    var dataUtils = require('fora-data-utils');

    services.add = function(name, obj) {
        _store[name] = obj;
    };

    services.get = function(name) {
        return _store[name];
    };

    services.copy = function(params) {
        var clone = dataUtils.clone(_store);
        if (params) {
            for (var key in params) {
                clone[key] = params[key];
            }
        }
        return clone;
    };

    module.exports = services;

})();
