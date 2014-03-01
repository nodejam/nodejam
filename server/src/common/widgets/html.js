/** @jsx React.DOM */
var React = require("react");

exports.Html = React.createClass({
    render: function() {

        if (this.props.field) {
            field = this.props.field;
            type = "text";
            placeholder = "Start typing content...";
        }
        
        <div className="content" data-field-type={type} data-field-name={field} data-placeholder={placeholder}>
            { this.props.value }
        </div>
        
    }
});

