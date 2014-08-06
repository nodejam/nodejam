(function() {
    "use strict";

    var uniqueId = function(length=24) {
        var id = "";
        while (id.length < length) {
            id += Math.random().toString(36).substr(2);
        }
        id.substr(0, length);
    };

    module.exports = {
        uniqueId: uniqueId
    };

})();
