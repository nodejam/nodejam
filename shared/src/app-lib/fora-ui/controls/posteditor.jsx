/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react');

    module.exports = React.createClass({
        render: function() {
            var json = JSON.stringify(this.props.post);
            var typeDefinition = JSON.stringify(this.props.typeDefinition);
            var script = "new Fora.Views.Posts.Post(\"" + json + "\", \"" + typeDefinition + "\");";
            script = <script type="text/javascript" dangerouslySetInnerHTML={{__html: script}}></script>;
            return script;   
        }
    });
})();
