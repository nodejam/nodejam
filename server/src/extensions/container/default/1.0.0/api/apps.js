(function() {
    "use strict";

    var _;

    var models = require('fora-lib-models'),
        services = require('fora-lib-services'),
        dataUtils = require('fora-lib-data-utils'),
        Parser = require('ceramic-dictionary-parser'),
        DbConnector = require('fora-lib-db-connector');


    var create = function*() {
        this.body = yield* models.App.createViaRequest(this);
    };


    var edit = function*(stub) {
        var appStore = new DbConnector(models.App);
        var app = yield* appStore.findOne({ stub: stub });
        this.body = yield* app.editViaRequest(this);
    };


    var auth = require('fora-lib-auth-service');
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit)
    };



})();
