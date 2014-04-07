/** @jsx React.DOM */
var React = require("react");
var widgets = require("widgets");

var Page = widgets.Page,
    Heading = widgets.Heading,
    Author = widgets.Author, 
    Html = widgets.Html;

module.exports = React.createClass({
    render: function() {
        forum = this.props.forum;

        if (!forum.cover) {
            forum.cover = {
                image: { 
                    src: '/images/forum-cover.jpg', 
                    small: '/images/forum-cover-small.jpg', 
                    alt: forum.name
                }
            };
        }
    
        createCard = function(post) {
                
        };
    
        return (
            <Page cover={this.props.forum.cover} type="forum" posts={this.props.posts} forum={this.props.forum}>
                
                <h1>Hello</h1>
                <Heading size="h1" field="title" title={this.props.post.title} />
                <Author type="small" forum={this.props.forum} author={this.props.author} />
                <Html field="content" html={this.props.post.content.formatContent()} />
            </Page>
        );
    }
});   
