/** @jsx React.DOM */
var React = require("react");
var Page = require('./page').Page;

exports.Post = React.createClass({
    render: function() {
        json = JSON.stringify(this.props.post);
        typeDefinition = JSON.stringify(this.props.typeDefinition);
        script = "new Fora.Views.Posts.Post(\"" + json + "\", \"" + typeDefinition + "\");";
        script = <script type="text/javascript"  dangerouslySetInnerHTML={{__html: script}}></script>;
        
        return (
            <Page cover={this.props.post.cover}>        
                {script}
                <div className="content-area upsize-text item">
                    {this.props.children}
                </div>
            </Page>
        );        
    }
});

