(function() {

    "use strict";

    var React = require('react'),
        services = require('fora-lib-services');

    var getWidget = function*(viewName, item) {
        var typesService = services.getTypesService();
        var extensionsService = services.getExtensionsService();

        var extensionSearchResult = yield extensionsService.get(item.type);
        if (extensionSearchResult) {
            var extension = extensionSearchResult.extension;
            if (!extension.__widgets)
                extension.__widgets = {};
            if (!extension.__widgets[viewName])
                extension.__widgets[viewName] = React.createFactory(extension.web.widgets[viewName]);
            return extension.__widgets[viewName];
        }
    };

    module.exports = {
        getWidget: getWidget
    };

})();
