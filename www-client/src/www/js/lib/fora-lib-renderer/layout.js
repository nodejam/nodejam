(function() {
    "use strict";

    var React = require('react');
    var pageContainer = require('fora-lib-ui').PageContainer;


    //IE9 doesn't have classList. That's the least IE version we'll support.
    //Also, IE should go die.
    var hasClass = (typeof document.documentElement.classList == "undefined") ?
        function(el, clss) {
            return el.className && new RegExp("(^|\\s)" +
                   clss + "(\\s|$)").test(el.className);
        } :
        function(el, clss) {
            return el.classList.contains(clss);
        };


    var render = function(debug) {
        return function*(request, reactClass, api) {
            var props;

            if (reactClass.componentInit)
                props = yield* reactClass.componentInit.call(null, api);

            props = props || {};

            var component = React.createFactory(reactClass)(props);

            document.title = props.title || "The Fora Project";

            var pageName = props.pageName || "default-page";
            var theme = props.theme || "default-theme";

            [pageName, theme].forEach(function(bodyClass) {
                if (!hasClass(document.body, bodyClass)) {
                    if (document.body.classList)
                        document.body.classList.add(bodyClass);
                    else
                        el.className += ' ' + bodyClass;
                }
            });

            var container = React.createElement(pageContainer, { page: component });
            React.render(container, document.getElementsByClassName('app-container')[0]);
        };
    };


    module.exports = {
        render: render(false),
        render_DEBUG: render(true)
    };

})();
