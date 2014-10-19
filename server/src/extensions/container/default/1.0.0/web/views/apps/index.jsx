/** @jsx React.DOM */
(function() {
    "use strict";

    var _;

    var React = require("react");

    var UI = require('fora-app-ui');
    var Page = UI.Page,
        Cover = UI.Cover,
        Content = UI.Content;

    var services = require("fora-app-services");
    var config = services.get("configuration");

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
                <Page>
                    <Content>
                        <nav>
                            <ul>
                                <li>
                                    {config.typeAliases.record.displayPlural}
                                </li>
                                <li className="selected">
                                    <a href={"/" + config.typeAliases.app.plural}>{config.typeAliases.app.displayPlural}</a>
                                </li>
                            </ul>
                        </nav>
                        <div className="content-area wide">
                            <ul className="articles card-view">
                                {this.props.apps.map(createItem)}
                            </ul>
                        </div>
                    </Content>
                </Page>
            );
        }
    });

})();
