/** @jsx React.DOM */
var React = require("react-sandbox");
var ForaUI = require("fora-ui");
var Page = ForaUI.Page,
    Content = ForaUI.Content;

exports.Index = React.createClass({
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
