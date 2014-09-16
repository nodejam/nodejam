(function() {
    "use strict";

    var _;
    var services = require('fora-app-services');


    var index = function*() {
        this.body = "AGAIN!";
        return;
        yield false; //browerify BS!
    };

    module.exports = {
        index: index
    };

})();
