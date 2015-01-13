(function() {
    "use strict";

    var _;

    var models = require('fora-lib-models'),
        services = require('fora-lib-services'),
        DbConnector = require('fora-lib-db-connector');


    var index = function*() {
        var appStore = new DbConnector(models.App);
        this.body = { apps: yield appStore.find({}, { sort: { 'stats.lastRecord': -1 }, limit: 32 }) };
    };


    module.exports = { index: index };

})();
