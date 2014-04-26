/** @jsx React.DOM */
var root = (typeof exports !== "undefined" && exports !== null) ? exports : this.ForaUI;

if (typeof exports !== "undefined" && exports !== null) {
    var React = require("react-sandbox");
}

//fugly code until we get destructuring in ES6
Cover = require('./cover').Cover;

root.Page = React.createClass({
    render: function() {
        return (
            <div className="single-section-page">
                {this.props.children}
            </div>
        );        
    }
});
