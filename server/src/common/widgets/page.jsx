/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
Cover = require('./cover').Cover;

exports.Page = React.createClass({
    render: function() {
        var cover = <Cover cover={this.props.cover} />
        
        return (
            <div className="single-section-page single-column">
                {cover}                
                <div className="main-pane">
                    <div className="content-area upsize-text item">
                        {this.props.children}
                    </div>
                </div>
            </div>
        );        
    }
});
