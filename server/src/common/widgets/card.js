/** @jsx React.DOM */
var React = require("react");

exports.Card = React.createClass({
    render: function() {
    
        <div>
            <div className="card-face">
                { this.props.image ? 
                    <div className="image" style="background-image:url({this.props.image.src})"></div> 
                    : <span>Hello world</span>
                }
            </div>
            <div className="card-content">
                {this.props.children}            
            </div>
        </div>
        
    }
});



