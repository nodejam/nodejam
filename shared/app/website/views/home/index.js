/** @jsx React.DOM */
var React = require('react');
var ExtensionLoader = require('fora-extensions').Loader;
var Models = require('../../../models');

var Page = ForaUI.Page,
    Content = ForaUI.Content,
    Cover = ForaUI.Cover,
    loader = new ExtensionLoader();

module.exports = React.createClass({displayName: 'exports',
    componentInit: function*(component, isBrowser) {           
        /* Convert the JSON into Post objects and attach the templates */
        postsData = [this.props.featured, this.props.editorsPicks];
        for(_i = 0; _i < postsData.length; _i++) {
            posts = postsData[_i];
            for (i = 0; i < posts.length; i++) {
                if (!(posts[i] instanceof Models.Post))
                    posts[i] = new Models.Post(posts[i]);
                extension = yield loader.load(yield posts[i].getTypeDefinition());
                posts[i].template = yield extension.getTemplateModule('list');
            }
        }
    },

    render: function() {        
        createItem = function(post) {
            return post.template({ key: post._id, post: post, forum: post.forum, author: post.createdBy });
        };    
    
        return (
            Page(null, 
                Cover( {cover:this.props.cover, coverContent:this.props.coverContent} ),
                Content(null, 
                    React.DOM.nav(null, 
                        React.DOM.ul(null, 
                            React.DOM.li( {className:"selected"}, 
                                "Posts"
                            ),
                            React.DOM.li(null, 
                                React.DOM.a( {href:"/forums"}, "Forums")
                            )            
                        )
                    ),
                    React.DOM.div( {className:"content-area"}, 
                        React.DOM.ul( {className:"articles default-view"}, 
                            this.props.editorsPicks.map(createItem)     
                        ),
                        React.DOM.ul( {className:"articles default-view"}, 
                            this.props.featured.map(createItem)     
                        )
                    )
                )
            )        
        );
    }
});

