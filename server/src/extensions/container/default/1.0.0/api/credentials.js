(function() {
    "use strict";

    var _;

    var models = require('fora-lib-models'),
        services = require('fora-lib-services'),
        Parser = require('fora-request-parser');

    var conf = services.getConfiguration();

    var create = function*() {
        var credential = yield* models.Credential.createViaRequest(this);
        var session = yield* credential.createSession();
        this.body = { token: session.token };
    };

    module.exports = { create: create };

})();
