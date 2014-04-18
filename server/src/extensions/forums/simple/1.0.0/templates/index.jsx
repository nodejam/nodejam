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
    
        createItem = function(post) {
            return post.template({ post: post, forum: post.forum, author: post.createdBy });
        };    
    

        options = this.props.options;
        buttons = null;
        
        if (options.loggedIn) {
            if (options.isMember)
                action = <a href="#" className="positive new-post"><i className="fa fa-plus"></i>New {options.primaryPostType}</a>
            else
                action = <a href="#" className="positive join-forum"><i className="fa fa-user"></i>Join Forum</a>

            buttons = (
                <ul className="alt buttons">
                    <li>
                        {action}
                    </li>
                </ul>
            );          
        }

        return (
            <Page>
                <Cover cover={forum.cover} />                
                <Content>
                    <nav>
                        <ul>
                            <li className="selected">
                                Popular
                            </li>
                            <li>
                                <a href="/{{forum.stub}}/about">About</a>
                            </li>          
                        </ul>
                        {buttons}
                    </nav>    
                    <div className="content-area">
                        <ul className="articles default-view">
                            {this.props.posts.map(createItem)}     
                        </ul>
                    </div>
                </Content>
            </Page>        
        );
    }
});
