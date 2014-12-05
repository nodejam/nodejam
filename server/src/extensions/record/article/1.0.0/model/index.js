(function() {

    "use strict";

    var models = require('fora-lib-models');

    module.exports = models.Record.extend({
        my_getCacheItem: function*() {
            return {
                title: this.title,
                createdBy: this.createdBy,
                createdAt: this.createdAt,
                updatedAt: this.updatedAt
            };
        }
    });

})();
