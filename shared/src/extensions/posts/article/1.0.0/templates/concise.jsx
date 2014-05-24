/** @jsx React.DOM */
var React = require('react');
var ForaUI = require('fora-ui');

var PostEditor = ForaUI.PostEditor;

module.exports = React.createClass({
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

