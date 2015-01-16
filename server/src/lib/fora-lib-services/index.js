(function() {

    var _db, _configuration, _extensionsService, _schemaManager;

    var services = {
        copy: function(params) {
            return {
                db: _db,
                configuration: _configuration,
                extensionsService: _extensionsService,
                schemaManager: _schemaManager
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

        getSchemaManager: function() {
            return _schemaManager;
        },

        setTypesService: function(svc) {
            _schemaManager = svc;
        }
    };

    module.exports = services;

})();
