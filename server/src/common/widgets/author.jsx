/** @jsx React.DOM */
var React = require("react");

exports.Author = React.createClass({
    render: function() {
        assets = "/public/assets/" + this.props.author.assets;
        
        switch(this.props.type) {
            case "full":
                img = assets + "/" + this.props.author.username + "_t.jpg";
                return (
                    <div className="header stamp-block">
                        <img src={img} alt={this.props.author.name} />
                        <h2>{this.props.author.name}</h2>
                        <p>{this.props.author.about}</p>
                        <p><span className="light-text">Yesterday in <a href={this.props.forum.stub}>{this.props.forum.name}</a></span></p>     
                    </div>        
                );
            case "text":
                return (
                    <div className="content">            
                        <p className="sub-text">
                            <a href={"/~" + this.props.author.username}>{this.props.author.name}</a>
                            <span> in </span><a href={this.props.forum.stub}>{this.props.forum.name}</a><br />
                        </p>
                    </div>
                );
            default:
                img = assets + "/" + this.props.author.username + "_t.jpg";
                return (
                    <div className="icon-block">
                        <img src={img} alt={this.props.author.name} />
                        <div className="text">
                            <h4><a href={"/~" + this.props.author.username}>{this.props.author.name}</a></h4>
                            <span className="sub-text"> in <a href={this.props.forum.stub}>{this.props.forum.name}</a></span>
                        </div>
                    </div>
                );
        }                
    }
});

