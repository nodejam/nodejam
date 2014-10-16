/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react');

    module.exports = React.createClass({
        render: function() {
            return (
                <div className="single-section-page">
                    {this.props.children}
                </div>
            );
        }
    });

})();
