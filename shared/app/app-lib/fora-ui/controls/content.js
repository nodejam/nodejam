/** @jsx React.DOM */
React = require('react');

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        if (!this.props.type)
            className = "main-pane";
        else
            className = this.props.type + "-" + pane;
        return (
            React.DOM.div( {className:className}, 
                this.props.children
            )
        );        
    }
});

