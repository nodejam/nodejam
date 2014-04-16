/** @jsx React.DOM */
var React = require("react");

module.exports = React.createClass({
    render: function() {
        json = JSON.stringify(this.props.post);
        typeDefinition = JSON.stringify(this.props.typeDefinition);
        script = "new Fora.Views.Posts.Post(\"" + json + "\", \"" + typeDefinition + "\");";
        script = <script type="text/javascript"  dangerouslySetInnerHTML={{__html: script}}></script>;        
        return script;   
    }
});

