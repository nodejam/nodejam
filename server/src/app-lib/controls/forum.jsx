/** @jsx React.DOM */
var React = require("react");
var Page = require('./page').Page;

exports.Forum = React.createClass({
    render: function() {
        forum = this.props.forum;
        
        //If the cover is missing, use default
        if (!forum.cover) {
            forum.cover = {
                image: { 
                    src: '/images/forum-cover.jpg', 
                    small: '/images/forum-cover-small.jpg', 
                    alt: forum.name
                }
            };
        }
        
        if (!forum.cover.type) {
            forum.cover.type = "auto-cover"
        }
    
        return (
            <Page cover={forum.cover}>
                <div className="content-area">
                    <ul className="cards row-layout">
                        {this.props.children}
                    </ul>
                </div>
            </Page>
        );        
    }
});

