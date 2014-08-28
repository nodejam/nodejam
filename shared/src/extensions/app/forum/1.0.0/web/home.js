(function() {
    "use strict";

    var _;
    var services = require('fora-app-services');


    var home = function*() {
        this.body = "AGAIN!";
    };

    var auth = require('fora-app-auth-service');
    module.exports = {
        home: home
    };

})();
