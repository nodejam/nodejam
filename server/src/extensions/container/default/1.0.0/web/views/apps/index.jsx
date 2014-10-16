/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require("react");

    var UI = require('fora-app-ui');
    var Page = UI.Page,
        Cover = UI.Cover,
        Content = UI.Content;

    module.exports = React.createClass({
        statics: {
            componentInit: function*(api) {
                var props = yield* api.http.get("/api/v1/ui/apps");

                for (var i = 0; i < props.apps.length; i++) {
                      records[i].template = yield* api.views.getView("list", records[i]);
                }

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
                                    Records
                                </li>
                                <li>
                                    <a href="/apps">Forums</a>
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
