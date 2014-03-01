/** @jsx React.DOM */
var React = require("react");

exports.Html = React.createClass({
    render: function() {
        var field, type, placeholder;
        
        if (this.props.field) {
            field = this.props.field;
            type = "text";
            placeholder = "Start typing content...";
        }
        
        return (
            <div className="content" dangerouslySetInnerHTML={{__html: this.props.html}}>
            </div>
        );        
    }
});

