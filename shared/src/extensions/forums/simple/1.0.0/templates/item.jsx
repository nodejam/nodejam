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
            componentInit: function*(component, isBrowser) {           
                /* Convert the JSON into Post objects and attach the templates */
                if (isBrowser)
                    component.props.post = new Models.Post(component.props.post);
                extension = yield loader.load(yield component.props.post.getTypeDefinition());
                component.props.post.template = yield extension.getTemplateModule(component.props.postTemplate);
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
