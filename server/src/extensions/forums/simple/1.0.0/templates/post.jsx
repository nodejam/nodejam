/** @jsx ui.DOM */
var ui = require("fora-ui");
var Page = ui.controls.Page;

module.exports = ui.createClass({
    render: function() {
        return (
            <Page cover={this.props.post.cover}>
                <div className="content-area item">
                    {
                        this.props.template({
                            post: this.props.post,
                            forum: this.props.forum,
                            author: this.props.author        
                        })
                    }
                </div>
            </Page>
        );
    }
});
