(function() {

    "use strict";

    var models = require('fora-app-models');

    module.exports = models.Record.extend({
        getCacheItem: function*() {
            return {
                title: this.title,
                createdBy: this.createdBy,
                createdAt: this.createdAt,
                updatedAt: this.updatedAt
            };
        }
    });

})();
