(function() {
    "use strict";

    var settings = require('./settings');

    settings.services = settings.services || {};
    settings.services.auth = settings.services.auth || {};
    settings.services.extensions = settings.services.extensions || {};
    settings.services.file = settings.services.file || {};

    var typeAliases = settings.typeAliases || {
        app: { singular: "app", plural: "apps", singularText: "App", pluralText: "Apps" },
        record: { singular: "records", plural: "records", singularText: "Record", pluralText: "Records"  }
    };

    module.exports = {
        domains: settings.domains,
        db: settings.db,
        admins: settings.admins,
        apiContainer: settings.apiContainer,
        webContainer: settings.webContainer,
        services: settings.services,
        extensions: settings.extensions,
        reservedNames: settings.reservedNames,
        typeAliases: typeAliases
    };

})();
