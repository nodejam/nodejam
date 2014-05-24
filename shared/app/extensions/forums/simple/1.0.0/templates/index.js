/** @jsx React.DOM */
React = require('react');
ForaUI = require('fora-ui');
ExtensionLoader = require('fora-extensions').Loader;
Models = require('../../../../../models');

var Page = ForaUI.Page,
    Content = ForaUI.Content,
    Cover = ForaUI.Cover;

var loader = new ExtensionLoader();
    
module.exports = React.createClass({displayName: 'exports',
    statics: {
        componentInit: function*(component, isBrowser) {           
            /* Convert the JSON into Post objects and attach the templates */
            posts = component.props.posts;
            for (i = 0; i < posts.length; i++) {
                if (isBrowser)
                    posts[i] = new Models.Post(posts[i]);
                extension = yield loader.load(yield posts[i].getTypeDefinition());
                posts[i].template = yield extension.getTemplateModule(component.props.postTemplate);
            }
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
                action = React.DOM.a( {href:"#", className:"positive new-post"}, React.DOM.i( {className:"fa fa-plus"}),"New ", options.primaryPostType)
            else
                action = React.DOM.a( {href:"#", className:"positive join-forum"}, React.DOM.i( {className:"fa fa-user"}),"Join Forum")

            buttons = (
                React.DOM.ul( {className:"alt buttons"}, 
                    React.DOM.li(null, 
                        action
                    )
                )
            );          
        }

        return (
            Page(null, 
                Cover( {cover:forum.cover} ),                
                Content(null, 
                    React.DOM.nav(null, 
                        React.DOM.ul(null, 
                            React.DOM.li( {className:"selected"}, 
                                "Popular"
                            ),
                            React.DOM.li(null, 
                                React.DOM.a( {href:"/{{forum.stub}}/about"}, "About")
                            )          
                        ),
                        buttons
                    ),    
                    React.DOM.div( {className:"content-area"}, 
                        React.DOM.ul( {className:"articles default-view"}, 
                            this.props.posts.map(createItem)     
                        )
                    )
                )
            )        
        );
    }
});

