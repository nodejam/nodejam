(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services');


    var index = function*() {
        this.body = { apps: yield* models.App.find({}, { sort: { 'stats.lastRecord': -1 }, limit: 32 }) };
    };


    module.exports = { index: index };

})();
