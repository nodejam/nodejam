(function() {

    "use strict";

    var dataUtils = require('fora-data-utils');
    
    var AppSummary = function(params) {
        dataUtils.extend(this, params);
    };

    AppSummary.entitySchema = {
        name: "app-summary",
        schema: {
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
