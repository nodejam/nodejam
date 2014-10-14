/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react');

    module.exports = React.createClass({
        getInitialState: function() {
            return { page: this.props.page };
        },

        render: function() {
            return (
                <div className="page-container">
                    {this.state.page}
                </div>
            );
        }
    });

})();
