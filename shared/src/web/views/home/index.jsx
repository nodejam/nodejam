/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require("react");

    module.exports = React.createClass({
        statics: {
            componentInit: function*(props) {
                /* Convert the JSON into Record objects and attach the templates */
                var init = function*(records) {
                  for (var i = 0; i < records.length; i++) {
                      if (!(records[i] instanceof Models.Record)) records[i] = new Models.Record(records[i]);
                      var typeDef = yield* records[i].getTypeDefinition();
                      var extension = yield* loader.load(typeDef);
                      records[i].template = yield* extension.getTemplateModule('list');
                  }
                }

                yield* init(props.featured);
                yield* init(props.editorsPicks);

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
                                    <a href="/s">Forums</a>
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
