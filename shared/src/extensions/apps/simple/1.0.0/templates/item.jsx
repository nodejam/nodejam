/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react'),
        ForaUI = require('fora-ui'),
        ExtensionLoader = require('fora-extensions').Loader,
        Models = require('../../../../../models');

    var Page = ForaUI.Page,
        Cover = ForaUI.Cover,
        Content = ForaUI.Content;

    var loader = new ExtensionLoader();

    module.exports = React.createClass({
        statics: {
            componentInit: function*(props) {
                /* Convert the JSON into a Record object and attach the templates */
                if (!(props.record instanceof Models.Record)) props.record = new Models.Record(props.record);
                var typeDef = yield props.record.getTypeDefinition();
                var extension = yield loader.load(typeDef);
                props.record.template = yield extension.getTemplateModule('item');
                return props;
            }
        },

        render: function() {
            return (
                <Page cover={this.props.record.cover}>
                    <Cover cover={this.props.record.cover} />
                    <Content>
                        <div className="content-area item">
                            {
                                this.props.record.template({
                                    record: this.props.record,
                                    app: this.props.app,
                                    author: this.props.author
                                })
                            }
                        </div>
                    </Content>
                </Page>
            );
        }
    });

})();
