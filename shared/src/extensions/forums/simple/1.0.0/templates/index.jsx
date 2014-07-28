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
                var posts = props.posts;
                for (var i = 0; i < posts.length; i++) {
                    if (!(posts[i] instanceof Models.Post)) posts[i] = new Models.Post(props.post);
                    var typeDef = yield* posts[i].getTypeDefinition();
                    var extension = yield* loader.load(yield* posts[i].getTypeDefinition());
                    posts[i].template = yield* extension.getTemplateModule(props.postTemplate);
                }
                return props;
            }
        },

        render: function() {
            var forum = this.props.forum;

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

            var createItem = function(post) {
                return post.template({ post: post, forum: post.forum, author: post.createdBy });
            };


            var options = this.props.options;
            var buttons = null;

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
