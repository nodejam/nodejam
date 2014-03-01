/** @jsx React.DOM */
var React = require("react");

//fugly code until we get destructuring in ES6
var _ = require("../../../../common/widgets");
var Card = _.Card, Heading = _.Heading, Author = _.Author, Html = _.Html;


module.exports = React.createClass({
    render: function() {
        var post = this.props.post;

        var image, text; 
        if(post.cover)
            image = post.cover.image;
        else
            text = "No-image!";

        //If synopsis is not given, try to auto-generate it.
        if (post.synopsis)
            synopsis = post.synopsis;
        else {
            if (post.content && post.content.format === 'markdown') {
                //Take the first two lines if synopsis is empty.
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
        
        if (typeof synopsis === "undefined")
            synopsis = post.content.text;
        
        return (
            <Card image={image} text={text}>
                <Heading size="h2" link={"/" + this.props.forum.stub + "/" + post.stub } title={post.title} />
                <Html value={synopsis} />
                <Author forum={this.props.forum} author={this.props.author} />
            </Card>
        );
    }
});


