/** @jsx React.DOM */
var React = require("react");

exports.Author = React.createClass({
    render: function() {
        assets = "/public/assets/" + this.props.author.assets;
        img = assets + "/" + this.props.author.username + ".jpg";
        
        <div className="header stamp-block">
            <img src={img} alt={this.props.author.name} />
            <h2>
                {this.props.author.name}
            </h2>
            <p>
                {this.props.author.about}
            </p>
            <p>
                <span className="light-text">Yesterday in <a href={this.props.forum.stub}>{this.props.forum.name}</a></span>
            </p>     
        </div>        
    }
});

