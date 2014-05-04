/** @jsx React.DOM */
fn = function(React, ForaUI) {
    return React.createClass({
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
                image = <div className="image" style={style}></div>
            }
            else
                image = null;
                
            return (
                <li>
                    {image}
                    <article onClick={function(){ alert("hello"); }}>
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
};

loader = function(definition) {
    if (typeof exports === "object")
        module.exports = definition(require('react'), require('fora-ui'));
    else
        define([], function() { return definition(React, ForaUI); });
}

loader(fn);

