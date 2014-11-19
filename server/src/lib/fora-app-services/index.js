(function() {

    var _db, _configuration, _extensionsService, _typesService;

    var services = {
        copy: function(params) {
            return {
                db: _db,
                configuration: _configuration,
                extensionsService: _extensionsService,
                typesService: _typesService
            };
        },

        getDb: function() {
            return _db;
        },

        setDb : function(svc) {
            _db = svc;
        },

        getConfiguration: function() {
            return _configuration;
        },

        setConfiguration : function(svc) {
            _configuration = svc;
        },

        getExtensionsService: function() {
            return _extensionsService;
        },

        setExtensionsService : function(svc) {
            _extensionsService = svc;
        },

        getTypesService: function() {
            return _typesService;
        },

        setTypesService: function(svc) {
            _typesService = svc;
        }
    };

    module.exports = services;

})();
