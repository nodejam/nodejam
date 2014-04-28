/** @jsx React.DOM */

fn = function(React) {
    return React.createClass({
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
}

loader = function(definition) {
    if (typeof exports === "object")
        module.exports = definition(require('react'));
    else
        window.ForaUI.Content = definition(React);
}

loader(fn);

