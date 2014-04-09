/** @jsx React.DOM */
var React = require("react");
var widgets = require("widgets");
var Forum = widgets.Forum;

module.exports = React.createClass({
    render: function() {        
        createCard = function(post) {
            return post.template({ post: post, forum: post.forum, author: post.createdBy });
        };    
    
        return (
            <Forum forum={this.props.forum} options={this.props.options}>
                {this.props.posts.map(createCard)}     
            </Forum>
        );
    }
});
