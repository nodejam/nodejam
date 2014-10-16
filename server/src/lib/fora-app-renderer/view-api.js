(function() {

    "use strict";

    var services = require('fora-app-services');

    var getWidget = function*(viewName, record) {
        var typesService = services.get('typesService');
        var extensionsService = services.get('extensionsService');

        var typeDef = yield* record.getTypeDefinition(typesService);
        var extensionSearchResult = yield* extensionsService.get(typeDef.name);
        if (extensionSearchResult) {
            var extension = extensionSearchResult.extension;
            return extension.web.widgets[viewName];
        }
    };

    module.exports = {
        getWidget: getWidget
    };

})();
