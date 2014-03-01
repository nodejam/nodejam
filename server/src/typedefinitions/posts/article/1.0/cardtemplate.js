/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
var _ = require("../../../common/widgets");
var Card = _.Card, Heading = _.Heading, Author = _.Author, Html = _.Html;


exports.CardTemplate = React.createClass({
    render: function() {
        return (
            <Card image={this.props.post.cover.image}>
                <Heading size="h2" field={this.props.post.title} />
                <Html field={this.props.post.content} />
                <Author field={this.props.post.createdBy} />
            </Card>
        );
    }
});


