(function() {
    "use strict";

    var React = require('react');

    module.exports = React.createClass({
        render: function() {
            return (
                <div className="site-options">
                    <ul>
                        <li><a href="/"><i className="fa fa-home"></i>Home</a></li>
                        <li><a href="/apps"><i className="fa fa-list"></i>Forums</a></li>
                    </ul>
                    <div className="transparent-overlay" onClick={this.props.closeHandler}>
                    </div>
                </div>
            );
        }
    });
})();
