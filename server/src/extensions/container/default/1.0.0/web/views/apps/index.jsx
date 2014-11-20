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
                                    {config.typeAliases.record.pluralText}
                                </li>
                                <li className="selected">
                                    <a href={"/" + config.typeAliases.app.plural}>{config.typeAliases.app.pluralText}</a>
                                </li>
                            </ul>
                        </nav>
                        <div className="content-area wide">
                            <ul className="articles card-view">
                                {this.props.apps.map(createItem)}
                            </ul>
                        </div>
                    </UI.Content>
                </UI.Page>
            );
        }
    });

})();
