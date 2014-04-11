/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
Cover = require('./cover').Cover;

exports.Page = React.createClass({
    render: function() {
        return (
            <div className="single-section-page single-column">
                <Cover cover={this.props.cover} />
                <div className="main-pane">
                    {this.props.children}
                </div>
            </div>
        );        
    }
});
