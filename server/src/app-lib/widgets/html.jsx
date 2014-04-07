/** @jsx React.DOM */
var React = require("react");

exports.Html = React.createClass({
    render: function() {
        return (
            <div className="content" dangerouslySetInnerHTML={{__html: this.props.html}}>
            </div>
        );        
    }
});

