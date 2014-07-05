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
                /* Convert the JSON into Post objects and attach the templates */
                for (i = 0; i < props.posts.length; i++) {
                    if (!(props.posts[i] instanceof Models.Post)) props.posts[i] = new Models.Post(props.post);
                    var typeDef = yield props.posts[i].getTypeDefinition();
                    var extension = yield loader.load(yield props.posts[i].getTypeDefinition());
                    props.posts[i].template = yield extension.getTemplateModule(props.postTemplate);
                }
                return props;
            }
        },

        render: function() {
            forum = this.props.forum;

            //If the cover is missing, use default
            if (!forum.cover) {
                forum.cover = {
                    image: {
                        src: '/images/forum-cover.jpg',
                        small: '/images/forum-cover-small.jpg',
                        alt: forum.name
                    }
                };
            }

            if (!forum.cover.type) {
                forum.cover.type = "auto-cover"
            }

            createItem = function(post) {
                return post.template({ post: post, forum: post.forum, author: post.createdBy });
            };


            options = this.props.options;
            buttons = null;

            if (options.loggedIn) {
                if (options.isMember)
                    action = <a href="#" className="positive new-post"><i className="fa fa-plus"></i>New {options.primaryPostType}</a>
                else
                    action = <a href="#" className="positive join-forum"><i className="fa fa-user"></i>Join Forum</a>

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
                    <Cover cover={forum.cover} />
                    <Content>
                        <nav>
                            <ul>
                                <li className="selected">
                                    Popular
                                </li>
                                <li>
                                    <a href="/{{forum.stub}}/about">About</a>
                                </li>
                            </ul>
                            {buttons}
                        </nav>
                        <div className="content-area">
                            <ul className="articles default-view">
                                {this.props.posts.map(createItem)}
                            </ul>
                        </div>
                    </Content>
                </Page>
            );
        }
    });

})();
