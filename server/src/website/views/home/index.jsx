/** @jsx React.DOM */
var React = require("reactjs-sandbox");
var ui = require("fora-ui");
var Page = ui.controls.Page,
    Content = ui.controls.Content;

module.exports = React.createClass({
    render: function() {        
        createItem = function(post) {
            return post.template({ post: post, forum: post.forum, author: post.createdBy });
        };    
    
        return (
            <Page>
                <Cover cover={this.props.cover} coverContent={this.props.coverContent} />
                <Content>
                    <nav>
                        <ul>
                            <li className="selected">
                                Posts
                            </li>
                            <li>
                                <a href="/forums">Forums</a>
                            </li>            
                        </ul>
                    </nav>
                    <div className="content-area">
                        <ul className="articles default-view">
                            {this.props.editorsPicks.map(createItem)}     
                        </ul>
                        <ul className="articles default-view">
                            {this.props.featured.map(createItem)}     
                        </ul>
                    </div>
                </Content>
            </Page>        
        );
    }
});
