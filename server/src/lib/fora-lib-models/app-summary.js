(function() {

    "use strict";

    var dataUtils = require('fora-lib-data-utils');

    var AppSummary = function(params) {
        dataUtils.extend(this, params);
    };

    AppSummary.entitySchema = {
        schema: {
            id: 'app-summary',
            type: 'object',
            properties: {
                id: {
                    type: 'string'
                },
                name: {
                    type: 'string'
                },
                stub: {
                    type: 'string'
                },
                createdBy: {
                    $ref: "user-summary"
                }
            },
            required: ['id', 'name', 'stub', 'createdBy']
        }
    };

    exports.AppSummary = AppSummary;

})();
