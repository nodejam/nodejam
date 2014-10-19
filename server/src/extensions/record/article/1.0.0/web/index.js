(function() {
    "use strict";

    module.exports = function() {
        return {
            widgets: {
                concise: require('./views/concise'),
                item: require('./views/item'),
                list: require('./views/list')
            }
        };
    };

})();
