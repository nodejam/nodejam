(function() {
    "use strict";

    var uniqueId = function(length) {
        length = length || 24;
        var id = "";
        while (id.length < length) {
            id += Math.random().toString(36).substr(2);
        }
        return id.substr(0, length);
    };

    module.exports = {
        uniqueId: uniqueId
    };

})();
