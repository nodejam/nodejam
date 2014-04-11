/** @jsx React.DOM */
var React = require("react");

exports.Item = React.createClass({
    render: function() {
        return (
            <div>
                {this.props.children}                
            </div>
        );
    }
});



