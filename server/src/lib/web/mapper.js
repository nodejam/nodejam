(function () {
    "use strict";

    var argv = require('optimist').argv;

    var Mapper = function (typesService) {
        this.typesService = typesService;
    };



    module.exports = Mapper;

})();
