(function() {
    "use strict";

    var React = require('react');


    module.exports = React.createClass({
        render: function() {
            var className;
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
