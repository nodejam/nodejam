/** @jsx React.DOM */
React = require('react');

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        return (
            React.DOM.div( {className:"single-section-page"}, 
                this.props.children
            )
        );        
    }
});

