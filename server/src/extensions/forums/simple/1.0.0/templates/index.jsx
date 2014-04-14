/** @jsx ui.DOM */
var ui = require("fora-ui");
var controls = require("controls");
var Forum = controls.Forum;

module.exports = ui.createClass({
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
