/** @jsx ui.DOM */
var ui = require("fora-ui");
var Page = ui.controls.Page,
    Content = ui.controls.Content;

module.exports = ui.createClass({
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
    
        createCard = function(post) {
            return post.template({ post: post, forum: post.forum, author: post.createdBy });
        };    
    
        return (
            <Page>
                <Cover cover={forum.cover} />                
                <Content>
                    <div className="content-area">
                        <ul className="articles default-view">
                            {this.props.posts.map(createCard)}     
                        </ul>
                    </div>
                </Content>
            </Page>        
        );
    }
});
