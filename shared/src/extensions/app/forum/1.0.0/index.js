(function() {
    "use strict";

    var api = require('./api');
    var web = require('./web');

    exports.init = function*() {
        yield api.init.call(this);
        yield web.init.call(this);
    };

})();
