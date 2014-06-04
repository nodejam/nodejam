/** @jsx React.DOM */
(function() {
    "use strict"

    var React = require('react'),
        ForaUI = require('fora-ui');

    var PostEditor = ForaUI.PostEditor;

    module.exports = React.createClass({
        render: function() {
            var post = this.props.post;
            var synopsis;

            //If synopsis is not given, try to auto-generate it.
            if (post.synopsis)
                synopsis = post.synopsis;
            else {
                /*
                    If it markdown formatted, take the first line.
                    If the first line is very short, take the second line too.
                */
                if (post.content && post.content.format === 'markdown') {
                    var sentence = post.content.text.match(/[^\.]+\./);
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
            
            var image;
            if (post.cover) {
                var style = {
                    backgroundImage: "url(" + post.cover.image.small + ")"
                };
                image = <div className="image" style={style}></div>
            }
            else
                image = null;
                
            return (
                <li>
                    {image}
                    <article>
                        <h2><a href={"/" + this.props.forum.stub + "/" + post.stub}>{post.title}</a></h2>
                        <p>{synopsis}</p>
                    </article>
                    <footer>
                        <a href={"/~" + this.props.author.username}>{this.props.author.name}</a> in <a href={this.props.forum.stub}>{this.props.forum.name}</a>
                    </footer>
                </li>
            );
        }
    });
})();
