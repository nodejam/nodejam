/** @jsx React.DOM */
var root = (typeof exports !== "undefined" && exports !== null) ? exports : this.ForaUI;

if (typeof exports !== "undefined" && exports !== null) {
    var React = require("react-sandbox");
}

root.Content = React.createClass({
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
