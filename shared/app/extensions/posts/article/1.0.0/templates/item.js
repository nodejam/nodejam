/** @jsx React.DOM */
var React = require('react');
var ForaUI = require('fora-ui');

var PostEditor = ForaUI.PostEditor;

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        return (
            React.DOM.article(null, 
                React.DOM.h1(null, this.props.post.title),
                React.DOM.section( {className:"author"}),
                React.DOM.section( {className:"content", dangerouslySetInnerHTML:{ __html: this.props.post.content.formatContent()}}
                )
            )            
        );
    }
});

