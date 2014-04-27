/** @jsx React.DOM */
var root = (typeof exports !== "undefined" && exports !== null) ? exports : this;

if (typeof exports !== "undefined" && exports !== null) {
    var React = require("react");
    var ForaUI = require("fora-ui");
}

var Page = ForaUI.Page,
    Content = ForaUI.Content;

root.Post = React.createClass({
    render: function() {
        return (
            <Page cover={this.props.post.cover}>
                <Cover cover={this.props.post.cover} />                
                <Content>            
                    <div className="content-area item">
                        {
                            this.props.template({
                                post: this.props.post,
                                forum: this.props.forum,
                                author: this.props.author        
                            })
                        }
                    </div>
                </Content>
            </Page>
        );
    }
});
