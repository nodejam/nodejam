/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
Cover = require('./cover').Cover;

exports.Page = React.createClass({
    render: function() {
        var cover;
        
        if (this.props.cover && this.props.cover.type === 'inline-cover')
            cover = <Cover cover={this.props.cover} />
        
        return (
            <div className="single-section-page single-column">
                <div className="main-pane">
                    {cover}                
                    <div className="content-area upsize item">
                        {this.props.children}
                    </div>
                </div>
            </div>
        );        
    }
});
