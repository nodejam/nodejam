(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        typeHelpers = require('fora-app-type-helpers'),
        conf = require('../../config');


    var index = function*() {
        this.body = "hello";
    };

    module.exports = { index: index };

})();
