/** @jsx React.DOM */
(function() {
    "use strict"
    var React = require('react'),
        ExtensionLoader = require('fora-extensions').Loader,
        ForaUI = require('fora-ui'),
        Models = require('../../../models');

    var Page = ForaUI.Page,
        Content = ForaUI.Content,
        Cover = ForaUI.Cover,
        loader = new ExtensionLoader();

    module.exports = React.createClass({
        componentInit: function*(component, isBrowser) {           
            /* Convert the JSON into Post objects and attach the templates */
            var postsData = [this.props.featured, this.props.editorsPicks];
            for(var _i = 0; _i < postsData.length; _i++) {
                var posts = postsData[_i];
                for (var i = 0; i < posts.length; i++) {
                    if (!(posts[i] instanceof Models.Post))
                        posts[i] = new Models.Post(posts[i]);
                    var extension = yield loader.load(yield posts[i].getTypeDefinition());
                    posts[i].template = yield extension.getTemplateModule('list');
                }
            }
        },

        render: function() {        
            var createItem = function(post) {
                return post.template({ key: post._id, post: post, forum: post.forum, author: post.createdBy });
            };    
        
            return (
                <Page>
                    <Cover cover={this.props.cover} coverContent={this.props.coverContent} />
                    <Content>
                        <nav>
                            <ul>
                                <li className="selected">
                                    Posts
                                </li>
                                <li>
                                    <a href="/forums">Forums</a>
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
