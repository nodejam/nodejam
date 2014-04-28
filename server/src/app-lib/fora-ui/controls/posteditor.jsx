/** @jsx React.DOM */
fn = function(React) {
    return React.createClass({
        render: function() {
            json = JSON.stringify(this.props.post);
            typeDefinition = JSON.stringify(this.props.typeDefinition);
            script = "new Fora.Views.Posts.Post(\"" + json + "\", \"" + typeDefinition + "\");";
            script = <script type="text/javascript" dangerouslySetInnerHTML={{__html: script}}></script>;        
            return script;   
        }
    });
}

loader = function(definition) {
    if (typeof exports === "object")
        module.exports = definition(require('react'));
    else
        window.ForaUI.PostEditor = definition(React);
}

loader(fn);
