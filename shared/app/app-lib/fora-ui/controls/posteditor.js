/** @jsx React.DOM */
React = require('react');

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        json = JSON.stringify(this.props.post);
        typeDefinition = JSON.stringify(this.props.typeDefinition);
        script = "new Fora.Views.Posts.Post(\"" + json + "\", \"" + typeDefinition + "\");";
        script = React.DOM.script( {type:"text/javascript", dangerouslySetInnerHTML:{__html: script}});
        return script;   
    }
});

