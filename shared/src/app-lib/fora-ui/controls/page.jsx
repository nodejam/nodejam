/** @jsx React.DOM */
React = require('react');

module.exports = React.createClass({
    render: function() {
        return (
            <div className="single-section-page">
                {this.props.children}
            </div>
        );        
    }
});

