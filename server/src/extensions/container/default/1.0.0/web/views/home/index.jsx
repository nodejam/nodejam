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
                var props = yield* api.http.get("/api/v1/ui/home");

                /* Attach the templates */
                var init = function*(items) {
                  for (var i = 0; i < items.length; i++) {
                      items[i].record.template = yield* api.views.getWidget("list", items[i].record);
                  }
                };

                _ = yield* init(props.featured);
                _ = yield* init(props.editorsPicks);

                return props;
            }
        },

        render: function() {
            var createItem = function(item) {
                return item.record.template({ key: item.record._id, record: item.record, app: item.app, author: item.record.createdBy });
            };

            return (
                <Page>
                    <Cover cover={this.props.cover} coverContent={this.props.coverContent} />
                    <Content>
                        <nav>
                            <ul>
                                <li className="selected">
                                    {config.typeAliases.record.displayPlural}
                                </li>
                                <li>
                                    <a href={"/" + config.typeAliases.app.plural}>{config.typeAliases.app.displayPlural}</a>
                                </li>
                            </ul>
                        </nav>
                        <div className="content-area">
                            <ul className="articles default-view">
                                {this.props.editorsPicks.map(createItem)}
                            </ul>
                            <ul className="articles default-view">
                                {this.props.featured.map(createItem)}
                            </ul>
                        </div>
                    </Content>
                </Page>
            );
        }
    });

})();
