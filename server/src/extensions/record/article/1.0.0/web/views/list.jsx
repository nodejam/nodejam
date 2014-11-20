(function() {
    "use strict";

    var React = require('react'),
        ForaUI = require('fora-app-ui');

    module.exports = React.createClass({
        render: function() {
            var record = this.props.record;
            var synopsis;

            //If synopsis is not given, try to auto-generate it.
            if (record.synopsis)
                synopsis = record.synopsis;
            else {
                /*
                    If it markdown formatted, take the first line.
                    If the first line is very short, take the second line too.
                */
                if (record.content && record.content.format === 'markdown') {
                    var sentence = record.content.text.match(/[^\.]+\./);
                    if (sentence) {
                        synopsis = sentence[0];

                        if (synopsis.length < 100) {
                            sentence = record.content.text.match(/[^\.]+\.[^\.]+\./i);

                            if (sentence && sentence[0].length < 400)
                                synopsis = sentence[0];
                        }
                    }
                }
            }

            //If synopsis isn't found just use content text. This is going to be truncated while displaying.
            if (typeof synopsis === "undefined")
                synopsis = record.content.text;

            var image;
            if (record.cover) {
                var style = {
                    backgroundImage: "url(" + record.cover.image.small + ")"
                };
                image = <div className="image" style={style}></div>;
            }
            else
                image = null;

            return (
                <li>
                    {image}
                    <article>
                        <h2><a href={"/" + this.props.app.stub + "/" + record.stub}>{record.title}</a></h2>
                        <p>{synopsis}</p>
                    </article>
                    <footer>
                        <a href={"/~" + this.props.author.username}>{this.props.author.name}</a> in <a href={this.props.app.stub}>{this.props.app.name}</a>
                    </footer>
                </li>
            );
        }
    });
})();
