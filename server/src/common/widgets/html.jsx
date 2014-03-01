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
            <div className="content" data-field-type={type} data-field-name={field} data-placeholder={placeholder} dangerouslySetInnerHTML={{__html: this.props.value}}>
            </div>
        );        
    }
});

