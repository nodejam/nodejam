/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react');

    var className;
    module.exports = React.createClass({
        render: function() {
            if (!this.props.type)
                className = "main-pane";
            else
                className = this.props.type + "-" + pane;
            return (
                <div className={className}>
                    {this.props.children}
                </div>
            );
        }
    });
})();
