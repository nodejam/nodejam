(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        Parser = require('fora-request-parser');

    var conf = services.get("configuration");

    var create = function*() {
        var credential = yield* models.Credential.createViaRequest(this);
        var session = yield* credential.createSession();
        this.body = { token: session.token };
    };

    module.exports = { create: create };

})();
