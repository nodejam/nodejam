/** @jsx React.DOM */
var root = (typeof exports !== "undefined" && exports !== null) ? exports : this;

if (typeof exports !== "undefined" && exports !== null) {
    var React = require("react");
    var ForaUI = require("fora-ui");
}

var PostEditor = ForaUI.PostEditor;

component = React.createClass({
    render: function() {
        return (
            <article>
                <PostEditor post={this.props.post} />
                <h1>{this.props.post.title}</h1>
                <section className="author"></section>
                <section className="content" dangerouslySetInnerHTML={{ __html: this.props.post.content.formatContent()}}>
                </section>
            </article>            
        );
    }
});

if (typeof exports !== "undefined" && exports !== null) {
    exports.Item = component;
} else {
    this.Article_1_0_0_Item = component;
}

