/** @jsx React.DOM */
var React = require("react");

exports.Text = React.createClass({
    render: function() {
        content = '<p>' + this.props.text.replace(/\n([ \t]*\n)+/g, '</p><p>')
                 .replace('\n', '<br />') + '</p>';
        return (
            <div className="content" dangerouslySetInnerHTML={{__html: content}}>
            </div>
        );
    }
});

