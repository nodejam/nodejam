/** @jsx React.DOM */
var React = require('react');
var ForaUI = require('fora-ui');

var PostEditor = ForaUI.PostEditor;

module.exports = React.createClass({displayName: 'exports',
    render: function() {
        var post = this.props.post;

        //If synopsis is not given, try to auto-generate it.
        if (post.synopsis)
            synopsis = post.synopsis;
        else {
            /*
                If it markdown formatted, take the first line.
                If the first line is very short, take the second line too.
            */
            if (post.content && post.content.format === 'markdown') {
                sentence = post.content.text.match(/[^\.]+\./);
                if (sentence) {
                    synopsis = sentence[0];

                    if (synopsis.length < 100) {
                        sentence = post.content.text.match(/[^\.]+\.[^\.]+\./i);

                        if (sentence && sentence[0].length < 400)
                            synopsis = sentence[0];
                    }                 
                }           
            }
        }
        
        //If synopsis isn't found just use content text. This is going to be truncated while displaying.        
        if (typeof synopsis === "undefined")
            synopsis = post.content.text;
        
        if (post.cover) {
            style = {
                backgroundImage: "url(" + post.cover.image.small + ")"
            };
            image = React.DOM.div( {className:"image", style:style})
        }
        else
            image = null;
            
        return (
            React.DOM.li(null, 
                image,
                React.DOM.article(null, 
                    React.DOM.h2(null, React.DOM.a( {href:"/" + this.props.forum.stub + "/" + post.stub}, post.title)),
                    React.DOM.p(null, synopsis)
                ),
                React.DOM.footer(null, 
                    React.DOM.a( {href:"/~" + this.props.author.username}, this.props.author.name), " in ", React.DOM.a( {href:this.props.forum.stub}, this.props.forum.name)
                )
            )
        );
    }
});
