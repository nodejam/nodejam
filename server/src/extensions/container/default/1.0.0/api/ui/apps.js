(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        DbConnector = require('fora-app-db-connector');


    var index = function*() {
        var appStore = new DbConnector(models.App);
        this.body = { apps: yield* appStore.find({}, { sort: { 'stats.lastRecord': -1 }, limit: 32 }) };
    };


    module.exports = { index: index };

})();
