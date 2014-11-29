(function() {
    "use strict";

    var _;

    var React = require("react");

    var UI = require('fora-app-ui');
    var services = require("fora-app-services");
    var config = services.getConfiguration();

    module.exports = React.createClass({
        statics: {
            componentInit: function*(api) {
                var props = yield* api.http.get("/api/v1/ui/apps");

                for (var i = 0; i < props.apps.length; i++) {
                      props.apps[i].template = yield* api.views.getWidget("list", props.apps[i]);
                }

                return props;
            }
        },

        render: function() {
            var createItem = function(app) {
                return app.template({ app: app });
            };

            return (
                <UI.Page>
                    <UI.Content>
                        <nav>
                            <ul>
                                <li>
                                    <a href="/">{config.typeAliases.record.pluralText}</a>
                                </li>
                                <li className="selected">
                                    {config.typeAliases.app.pluralText}
                                </li>
                            </ul>
                        </nav>
                        <div className="content-area wide">
                            <ul className="cards">
                                {this.props.apps.map(createItem)}
                            </ul>
                        </div>
                    </UI.Content>
                </UI.Page>
            );
        }
    });

})();
