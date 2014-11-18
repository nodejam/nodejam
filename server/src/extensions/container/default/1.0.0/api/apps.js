(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        dataUtils = require('fora-data-utils'),
        Parser = require('fora-request-parser'),
        DbConnector = require('fora-app-db-connector');


    var create = function*() {
        this.body = yield* models.App.createViaRequest(this);
    };


    var edit = function*(stub) {
        var appStore = new DbConnector(models.App);
        var app = yield* appStore.findOne({ stub: stub });
        this.body = yield* app.editViaRequest(this);
    };


    var auth = require('fora-app-auth-service');
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit)
    };



})();
