(function() {
    "use strict";

    var Network = require('../models/network').Network;

    //We will do everything synchronously.
    var fs = require('fs'),
        path = require('path');

    var networks = [];
    var files = fs.readdirSync(__dirname).filter(function(f) { return /\.config$/.test(f); });

    var settings;
    files.forEach(function(file) {
        var contents = JSON.parse(fs.readFileSync(path.resolve(__dirname, file)));

        switch (file) {
            case 'settings.config':
                settings = contents;
                break;
            default:
                networks.push(new Network(contents));
        }
    });

    if (!settings.fileService.publicDirectory) {
        settings.fileService.publicDirectory = path.resolve(__dirname, '../../../www-public');
    }

    if (!settings.extensionsService.extensionsDirectories) {
        settings.extensionsService.extensionsDirectories = [path.resolve(__dirname, '../extensions')];
    }

    module.exports = {
        app: settings.app,
        db: settings.db,
        auth: settings.auth,
        admins: settings.admins,
        applicationContainer: settings.applicationContainer,
        reservedNames: settings.reservedNames,
        networks: networks,
        userDirCount: 100
    };

})();
