/** @jsx React.DOM */

fn = function(React) {
    return React.createClass({
        render: function() {
            return (
                <div className="single-section-page">
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
        define(['react'], definition);
}

loader(fn);
