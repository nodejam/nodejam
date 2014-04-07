/** @jsx React.DOM */
var React = require("react");
var widgets = require("widgets");

var Page = widgets.Page,
    Heading = widgets.Heading,
    Author = widgets.Author, 
    Html = widgets.Html;

module.exports = React.createClass({
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
    
        createCard = function(post) {
            this.props.template({ post: post, forum: post.forum, author: post.createdBy });
        };
    
        return (
            <div className="single-section-page single-column">
                <Cover cover={forum.cover} />
                <div className="main-pane">
                    <div className="content-area upsize-text item">
                        {this.props.posts.map(createCard)}
                    </div>
                </div>
            </div>
        );
    }
});   
