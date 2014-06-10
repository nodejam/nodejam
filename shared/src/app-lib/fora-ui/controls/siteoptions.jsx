/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react');

    module.exports = React.createClass({
        render: function() {
            return (
                <div className="site-options">    
                    <ul>
                        <li><a href="/"><i className="fa fa-home"></i>Home</a></li>  
                        <li><a href="/forums"><i className="fa fa-list"></i>Forums</a></li>              
                        <li className="account"></li>  
                    </ul>
                    <div className="transparent-overlay">
                    </div>
                </div>
            );        
        }
    });
})();
