(function() {
    "use strict";

    var React = require('react');
    var pageContainer = require('fora-app-ui').PageContainer;


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

            var component = reactClass(props);

            document.title = props.title || "The Fora Project";

            var pageName = props.pageName || "default-page";
            var theme = props.theme || "default-theme";
            var bodyClass = pageName + " " + theme;

            if (!hasClass(document.body, "")) {
                if (document.body.classList)
                    document.body.classList.add(className);
                else
                    el.className += ' ' + className;
            }

            var container = pageContainer({ page: component });
            React.renderComponent(container, document.getElementsByClassName('app-container')[0]);
        };
    };


    module.exports = {
        render: render(false),
        render_DEBUG: render(true)
    };

})();
