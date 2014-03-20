/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
var widgets = require("widgets");
var Page = widgets.Page,
    Heading = widgets.Heading,
    Author = widgets.Author, 
    Html = widgets.Html;

module.exports = React.createClass({
    render: function() {
        return (
            <Page cover={this.props.post.cover}>
                <Heading size="h1" field="title" title={this.props.post.title} />
                <Author type="small" forum={this.props.forum} author={this.props.author} />
                <Html field="content" html={this.props.post.content.formatContent()} />
            </Page>
        );
    }
});   
