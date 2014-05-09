/** @jsx React.DOM */

fn = function(React, ForaUI) {
    var PostEditor = ForaUI.PostEditor;

    return React.createClass({
        render: function() {
            return (
                <article>
                    <h1>{this.props.post.title}</h1>
                    <section className="author"></section>
                    <section className="content" dangerouslySetInnerHTML={{ __html: this.props.post.content.formatContent()}}>
                    </section>
                </article>            
            );
        }
    });
}

loader = function(definition) {
    if (typeof exports === "object")
        module.exports = definition(require('react'), require('fora-ui'));
    else
        define([], function() { return definition(React, ForaUI); });
}

loader(fn);
