/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
var _ = require("../../../common/widgets");
var Page = _.Page, Cover = _.Cover, Heading = _.Heading, Author = _.Author, Html = _.Html;


exports.ItemTemplate = React.createClass({
    render: function() {
        return (
            <Page theme={this.props.theme} cover={this.props.post.cover}>
                <Heading size="h1" field="title" link={ "/" + this.props.forum.stub + "/" + this.props.post.stub } value={this.props.post.title} />
                <Author value={this.props.post.createdBy} />
                <Html field="content" value={this.props.post.content} />
            </Page>
        );
    }
});
