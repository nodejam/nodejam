(function() {
    "use strict";

    var _;
    var services = require('fora-app-services');


    var index = function*() {
        this.body = "AGAIN!";
    };

    var auth = require('fora-app-auth-service');
    module.exports = {
        index: index
    };

})();
