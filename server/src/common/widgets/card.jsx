/** @jsx React.DOM */
var React = require("react");

exports.Card = React.createClass({
    render: function() {
        var style = {}
        if (this.props.image)
            style = { 'background-image': 'url(' + this.props.image.src + ')' };
            
        return (
            <li>                
                { 
                    this.props.image ? 
                    <div className="card-face"><div className="image" style={style}></div></div>
                    : <div className="card-face empty"></div>
                }
                <div className="card-content">
                    {this.props.children}            
                </div>
            </li>
        );
    }
});



