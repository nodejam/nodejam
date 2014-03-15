/** @jsx React.DOM */
module.exports = function(require) {
    var React = require("react");

    //fugly code until we get destructuring in ES6
    var _ = require("widgets");
    var Page = _.Page, Heading = _.Heading, Author = _.Author, Html = _.Html;

    return React.createClass({
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
}

