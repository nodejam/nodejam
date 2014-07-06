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
                /* Convert the JSON into a Post object and attach the templates */
                if (!(props.post instanceof Models.Post)) props.post = new Models.Post(props.post);
                var typeDef = yield props.post.getTypeDefinition();
                var extension = yield loader.load(typeDef);
                props.post.template = yield extension.getTemplateModule('item');
                return props;
            }
        },

        render: function() {
            return (
                <Page cover={this.props.post.cover}>
                    <Cover cover={this.props.post.cover} />
                    <Content>
                        <div className="content-area item">
                            {
                                this.props.post.template({
                                    post: this.props.post,
                                    forum: this.props.forum,
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
