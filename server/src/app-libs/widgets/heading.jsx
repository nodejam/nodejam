/** @jsx React.DOM */
var React = require("react");

exports.Heading = React.createClass({
    render: function() {
        hx = React.DOM[this.props.size]
        if (this.props.link) {
            return (
                <hx>
                    <a href={this.props.link}>
                        {this.props.title}
                    </a>
                </hx>
            );
        }
        else {
            return (
                <hx>
                    {this.props.title}
                </hx>
            );
        }
    }
});
