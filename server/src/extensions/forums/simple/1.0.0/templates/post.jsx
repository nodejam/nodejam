/** @jsx React.DOM */
var React = require("react");
var widgets = require('widgets');
var Post = widgets.Post;

module.exports = React.createClass({
    render: function() {
        return (
            <Post post={this.props.post} typeDefinition={this.props.typeDefinition}>
                {
                    this.props.template({
                        post: this.props.post,
                        forum: this.props.forum,
                        author: this.props.author        
                    })
                }
            </Post>
        );
    }
});
