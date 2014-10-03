(function() {
    "use strict";

    var React = require('react');
    var PageContainer = require('fora-app-ui').PageContainer;

    var render = function(debug) {
        return function*(reactClass) {
            var props;

            if (reactClass.componentInit)
                props = yield* reactClass.componentInit.call(null, this);

            props = props || {};

            var component = reactClass(props);

            var title = props.title || "The Fora Project";
            var pageName = props.pageName || "default-page";
            var theme = props.theme || "default-theme";
            var bodyClass = pageName + " " + theme;

            var d = debug ? debug_deps : deps;
            var depsHtml = d.styles.map(function(x) { return makeLink(x); }).concat(d.scripts.map(function(x) { return makeScript(x); })).join('');

            depsHtml += '<script> initForaApp(); </script>';

            return (
                '<!DOCTYPE html>\
                <html>\
                    <head>\
                        <title>' + title + '</title>' +
                        depsHtml +
                        '<script>\
                            var __DEBUG = ' + debug ? "true" : "false" + ';\
                            var __apiCache = ' + JSON.stringify(this.apiCache) + ';\
                        </script>\
                        <meta name="viewport" content="width=device-width, initial-scale=1"/>\
                    </head>\
                    <body class="' + bodyClass + '">\
                        <!-- header -->\
                        <header class="site">\
                            <a href="#" class="logo">\
                                Fora\
                            </a>\
                        </header>\
                        <div class="page-container"> \
                        ' + React.renderComponentToString(component) + '\
                        </div>\
                    </body>\
                </html>');
            };
        };

    module.exports = {
        render: render(false),
        render_DEBUG: render(true)
    };

})();
