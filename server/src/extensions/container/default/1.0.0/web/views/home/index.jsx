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
                var init = function*(records) {
                  for (var i = 0; i < records.length; i++) {
                      records[i].template = yield* api.views.getWidget("list", records[i]);
                  }
                };

                _ = yield* init(props.featured);
                _ = yield* init(props.editorsPicks);

                return props;
            }
        },

        render: function() {
            var createItem = function(record) {
                return record.template({ key: record._id, record: record, app: record.app, author: record.createdBy });
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
