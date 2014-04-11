/** @jsx React.DOM */
var React = require("react");
var controls = require('controls');
var Post = controls.Post;

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
