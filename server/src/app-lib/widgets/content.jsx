/** @jsx React.DOM */
var React = require("react");

exports.Content = React.createClass({
    render: function() {
        content = this.props.content.formatContent();
        return (
            <div dangerouslySetInnerHTML={{__html: content}}>
                {this.props.children}                
            </div>
        );
    }
});



