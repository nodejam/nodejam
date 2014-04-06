/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
Cover = require('./cover').Cover;

exports.Page = React.createClass({
    render: function() {
        if (this.props.type === "post") {
            json = JSON.stringify(this.props.post);
            typeDefinition = JSON.stringify(this.props.typeDefinition);
            script = "new Fora.Views.Posts.Post(\"" + json + "\", \"" + typeDefinition + "\");";
            script = <script type="text/javascript"  dangerouslySetInnerHTML={{__html: script}}></script>;
        }
        else {
            script = '';
        }
        
        return (
            <div className="single-section-page single-column">
                {script}
                <Cover cover={this.props.cover} />                
                <div className="main-pane">
                    <div className="content-area upsize-text item">
                        {this.props.children}
                    </div>
                </div>
            </div>
        );        
    }
});
