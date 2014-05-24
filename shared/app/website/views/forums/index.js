/** @jsx React.DOM */
var React = require('react');
var ForaUI = require('fora-ui');
var ExtensionLoader = require('fora-extensions').Loader;
var Models = require('../../../models');

var Page = ForaUI.Page,
    Content = ForaUI.Content;

module.exports = React.createClass({displayName: 'exports',
    render: function() {        
        createItem = function(forum) {
            if (forum.cover) {
                style = {
                    backgroundImage: "url(" + forum.cover.image.small + ")"
                };
                image = React.DOM.div( {className:"image", style:style})
            }
            else
                image = null;
                
            return (
                React.DOM.li( {className:"col-span span5"}, 
                    image,
                    React.DOM.article(null, 
                        React.DOM.h2(null, React.DOM.a( {href:"/" + forum.stub}, forum.name)),
                        React.DOM.ul(null, 
                            
                                forum.cache.posts.map(function(post) {
                                    return (
                                        React.DOM.li(null, 
                                            React.DOM.a( {href:"/" + forum.stub + "/" + post.stub}, post.title),React.DOM.br(null ),
                                            React.DOM.span( {className:"subtext"}, post.createdBy.name)
                                        )
                                    );
                                })
                            
                        )
                    )
                )
            );
        };    

        return (
            Page(null, 
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
                    React.DOM.div( {className:"content-area wide"}, 
                        React.DOM.ul( {className:"articles card-view"}, 
                            this.props.forums.map(createItem)     
                        )
                    )
                )
            )        
        );
    }
});
Z
