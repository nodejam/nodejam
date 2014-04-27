/** @jsx React.DOM */
var root = (typeof exports !== "undefined" && exports !== null) ? exports : this.ForaUI;

if (typeof exports !== "undefined" && exports !== null) {
    var React = require("react");
}

root.PostEditor = React.createClass({
    render: function() {
        json = JSON.stringify(this.props.post);
        typeDefinition = JSON.stringify(this.props.typeDefinition);
        script = "new Fora.Views.Posts.Post(\"" + json + "\", \"" + typeDefinition + "\");";
        script = <script type="text/javascript" dangerouslySetInnerHTML={{__html: script}}></script>;        
        return script;   
    }
});

