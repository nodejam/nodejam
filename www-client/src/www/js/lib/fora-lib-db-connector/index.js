(function() {

    var services = require('fora-lib-services');

    var _svc;
    var getServices = function() {
        if (!_svc)
            _svc = services.copy();
        return _svc;
    };


    var Connector = function(ctor) {
        this.ctor = ctor;
    };


    Connector.getRowId = function(record) {
        var services = getServices();
        return services.db.getRowId(record);
    };


    Connector.setRowId = function(record, id) {
        var services = getServices();
        return services.db.setRowId(record, id);
    };


    module.exports = Connector;

})();
