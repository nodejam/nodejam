/** @jsx React.DOM */
var React = require("react");

exports.Page = React.createClass({
    render: function() {

        if(this.props.post.cover) {
            cover = <Cover field="cover" value={this.props.post.cover} />
        }
        
        return (
            <div className="single-section-page single-column">
                {cover}
                <div className="main-pane">
                    <div className="content-area upsize item">
                        {this.props.children}
                    </div>
                </div>
            </div>
        );        
    }
});
