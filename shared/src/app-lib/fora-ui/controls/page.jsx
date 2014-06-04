/** @jsx React.DOM */
(function() {
    "use strict"

    var React = require('react'),
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
    
})();
