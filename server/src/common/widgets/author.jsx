/** @jsx React.DOM */
var React = require("react");

exports.Author = React.createClass({
    render: function() {
        assets = this.props.author.getAssetUrl()
        
        switch(this.props.type) {
            case "full":
                img = assets + "/" + this.props.author.username + "_t.jpg";
                return (
                    <div className="header stamp-block">
                        <img src={img} alt={this.props.author.name} />
                        <h2>{this.props.author.name}</h2>
                        <p>{this.props.author.about}</p>
                        <p><span>Yesterday in <a href={this.props.forum.stub}>{this.props.forum.name}</a></span></p>     
                    </div>        
                );
            case "text":
                return (
                    <div className="content">            
                        <p className="downsize-text italics">
                            <a href={"/~" + this.props.author.username}>{this.props.author.name}</a>
                            <span> in </span><a href={this.props.forum.stub}>{this.props.forum.name}</a><br />
                        </p>
                    </div>
                );
            default:
                img = assets + "/" + this.props.author.username + "_t.jpg";
                return (
                    <div className="icon-block">
                        <div className="icon">
                            <img className="seal downsize" src={img} alt={this.props.author.name} />
                        </div>
                        <div className="text xdownsize-text">
                            <h4><a href={"/~" + this.props.author.username}>{this.props.author.name}</a></h4>
                            <p className="italics downsize-text"> in <a href={this.props.forum.stub}>{this.props.forum.name}</a></p>
                        </div>
                    </div>
                );
        }                
    }
});

