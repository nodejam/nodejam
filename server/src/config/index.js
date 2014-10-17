(function() {
    "use strict";

    //We will do everything synchronously.
    var fs = require('fs'),
        path = require('path');

    var settings = require('./settings');
    settings.services = settings.services || {};
    settings.services.auth = settings.services.auth || {};
    settings.services.extensions = settings.services.extensions || {};
    settings.services.file = settings.services.file || {};

    if (!settings.services.file.publicDirectory) {
        settings.services.file.publicDirectory = path.resolve(__dirname, '../../../www-public');
    }

    if (!settings.services.extensions.locations) {
        settings.services.extensions.locations = [path.resolve(__dirname, '../extensions')];
    }

    var typeAliases = settings.typeAliases || {
        app: { singular: "app", plural: "apps", displaySingular: "App", displayPlural: "Apps" },
        record: { singular: "records", plural: "records", displaySingular: "Record", displayPlural: "Records"  }
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
        serveStaticFiles: settings.serveStaticFiles,
        typeAliases: typeAliases
    };

})();
