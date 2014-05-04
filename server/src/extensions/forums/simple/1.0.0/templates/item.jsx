/** @jsx React.DOM */
fn = function(React, ForaUI) {
    var Page = ForaUI.Page,
        Content = ForaUI.Content,
        Cover = ForaUI.Cover;
    
    return React.createClass({
        render: function() {
            return (
                <Page cover={this.props.post.cover}>
                    <Cover cover={this.props.post.cover} />                
                    <Content>            
                        <div className="content-area item">
                            {
                                this.props.template({
                                    post: this.props.post,
                                    forum: this.props.forum,
                                    author: this.props.author        
                                })
                            }
                        </div>
                    </Content>
                </Page>
            );
        }
    });
}

loader = function(definition) {
    if (typeof exports === "object")
        module.exports = definition(require('react'), require('fora-ui'));
    else
        define([], function() { return definition(React, ForaUI); });
}

loader(fn);

