/** @jsx ui.DOM */
var ui = require("fora-ui");

var controls = require('controls');
var Post = controls.Post;

module.exports = ui.createClass({
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
