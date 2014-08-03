(function() {

    var services = {};

    var add = function(name, obj) {
        services[name] = obj;
    };

    var get = function(name) {
        return services[name];
    };

    module.exports = {
        add: add,
        get: get
    };
    
});
