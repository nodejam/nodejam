/** @jsx React.DOM */
var React = require("react");
var controls = require("controls");

var Item = controls.Item,
    Heading = controls.Heading,
    Author = controls.Author, 
    Content = controls.Content;

module.exports = React.createClass({
    render: function() {
        return (
            <Item>
                <Heading size="h1" field="title" title={this.props.post.title} />
                <Author type="small" forum={this.props.forum} author={this.props.author} />
                <Content field="content" content={this.props.post.content} />
            </Item>
        );
    }
});
