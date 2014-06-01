/** @jsx React.DOM */
React = require('react');
SiteOptions = require('./siteoptions');

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        return (
            React.DOM.div(null, 
                SiteOptions(null ),
                React.DOM.div( {className:"single-section-page"}, 
                    this.props.children
                )
            )
        );        
    }
});

