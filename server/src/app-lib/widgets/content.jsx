/** @jsx React.DOM */
var React = require("react");

exports.Content = React.createClass({
    render: function() {
    
        if (typeof this.props.content != "string")            
            content = this.props.content.formatContent();
        else
            content = this.props.content;
            
        return (
            <div className="content" dangerouslySetInnerHTML={{__html: content}}>
                {this.props.children}                
            </div>
        );
        
    }
});



