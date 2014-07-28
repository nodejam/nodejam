/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react'),
        ForaUI = require('fora-ui'),
        ExtensionLoader = require('fora-extensions').Loader,
        Models = require('../../../../../models');

    var Page = ForaUI.Page,
        Content = ForaUI.Content,
        Cover = ForaUI.Cover;

    var loader = new ExtensionLoader();


    module.exports = React.createClass({
        statics: {
            componentInit: function*(props) {
                /* Convert the JSON into Record objects and attach the templates */
                var records = props.records;
                for (var i = 0; i < records.length; i++) {
                    if (!(records[i] instanceof Models.Record)) records[i] = new Models.Record(props.record);
                    var typeDef = yield* records[i].getTypeDefinition();
                    var extension = yield* loader.load(yield* records[i].getTypeDefinition());
                    records[i].template = yield* extension.getTemplateModule(props.recordTemplate);
                }
                return props;
            }
        },

        render: function() {
            var app = this.props.app;

            //If the cover is missing, use default
            if (!app.cover) {
                app.cover = {
                    image: {
                        src: '/images/app-cover.jpg',
                        small: '/images/app-cover-small.jpg',
                        alt: app.name
                    }
                };
            }

            if (!app.cover.type) {
                app.cover.type = "auto-cover"
            }

            var createItem = function(record) {
                return record.template({ record: record, app: record.app, author: record.createdBy });
            };


            var options = this.props.options;
            var buttons = null;

            if (options.loggedIn) {
                if (options.isMember)
                    action = <a href="#" className="positive new-record"><i className="fa fa-plus"></i>New {options.primaryRecordType}</a>
                else
                    action = <a href="#" className="positive join-app"><i className="fa fa-user"></i>Join Forum</a>

                buttons = (
                    <ul className="alt buttons">
                        <li>
                            {action}
                        </li>
                    </ul>
                );
            }

            return (
                <Page>
                    <Cover cover={app.cover} />
                    <Content>
                        <nav>
                            <ul>
                                <li className="selected">
                                    Popular
                                </li>
                                <li>
                                    <a href="/{{app.stub}}/about">About</a>
                                </li>
                            </ul>
                            {buttons}
                        </nav>
                        <div className="content-area">
                            <ul className="articles default-view">
                                {this.props.records.map(createItem)}
                            </ul>
                        </div>
                    </Content>
                </Page>
            );
        }
    });

})();
