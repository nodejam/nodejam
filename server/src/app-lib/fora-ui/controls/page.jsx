/** @jsx React.DOM */
var React = require("react-sandbox");

//fugly code until we get destructuring in ES6
Cover = require('./cover');

module.exports = React.createClass({
    render: function() {
        return (
            <div className="single-section-page">
                {this.props.children}
            </div>
        );        
    }
});
