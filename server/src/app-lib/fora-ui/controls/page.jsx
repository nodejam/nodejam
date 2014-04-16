/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
Cover = require('./cover');

module.exports = React.createClass({
    render: function() {
        return (
            <div className="single-section-page">
                <Cover cover={this.props.cover} />
                <div className="main-pane">
                    {this.props.children}
                </div>
            </div>
        );        
    }
});
