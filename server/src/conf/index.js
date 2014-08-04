(function() {
    "use strict";

    //We will do everything synchronously.
    var fs = require('fs'),
        path = require('path');

    var settings = JSON.parse(fs.readFileSync(path.resolve(__dirname, "settings.config")));
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

    module.exports = {
        domains: settings.domains,
        db: settings.db,
        admins: settings.admins,
        applicationContainer: settings.applicationContainer,
        networks: networks,
        services: settings.services,
        extensions: settings.extensions,
        reservedNames: settings.reservedNames
    };

})();
