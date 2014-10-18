/** @jsx React.DOM */
(function() {
    "use strict";

    var React = require('react'),
        ForaUI = require('fora-app-ui');

    module.exports = React.createClass({
        render: function() {
            return (
                <article>
                    <h1>{this.props.record.title}</h1>
                    <section className="author"></section>
                    <section className="content" dangerouslySetInnerHTML={{ __html: this.props.record.content.formatContent()}}>
                    </section>
                </article>
            );
        }
    });
})();
