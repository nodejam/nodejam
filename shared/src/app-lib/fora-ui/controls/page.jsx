/** @jsx React.DOM */
React = require('react');
SiteOptions = require('./siteoptions');

module.exports = React.createClass({
    render: function() {
        return (
            <div>
                <SiteOptions />
                <div className="single-section-page">
                    {this.props.children}
                </div>
            </div>
        );        
    }
});

