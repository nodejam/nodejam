(function() {
    "use strict";

    var React = require('react');

    module.exports = React.createClass({
        render: function() {
            var json = JSON.stringify(this.props.record);
            var entitySchema = JSON.stringify(this.props.entitySchema);
            var script = "new Fora.Views.Records.Record(\"" + json + "\", \"" + entitySchema + "\");";
            script = <script type="text/javascript" dangerouslySetInnerHTML={{__html: script}}></script>;
            return script;
        }
    });
})();
