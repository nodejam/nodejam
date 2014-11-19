(function() {

    "use strict";

    var services = require('fora-app-services');

    var getWidget = function*(viewName, item) {
        var typesService = services.getTypesService();
        var extensionsService = services.getExtensionsService();

        var extensionSearchResult = yield* extensionsService.get(item.type);
        if (extensionSearchResult) {
            var extension = extensionSearchResult.extension;
            if (!extension.__widgets)
                extension.__widgets = extension.web.widgets;
            return extension.__widgets[viewName];
        }
    };

    module.exports = {
        getWidget: getWidget
    };

})();
