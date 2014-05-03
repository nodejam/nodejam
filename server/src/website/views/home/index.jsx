/** @jsx React.DOM */
fn = function(React, ForaUI, ExtensionLoader) {
    var Page = ForaUI.Page,
        Content = ForaUI.Content,
        Cover = ForaUI.Cover;

    return React.createClass({
        
        componentInit: function*() {
            loader = new ExtensionLoader()
            posts = this.props.featured.concat(this.props.editorsPicks);
            for (i = 0; i < posts.length; i++) {
                extension = yield loader.load(yield posts[i].getTypeDefinition());
                posts[i].template = yield extension.getTemplateModule('list');
            }
        },
    
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
}

loader = function(definition) {
    if (typeof exports === "object")
        module.exports = definition(require('react'), require('fora-ui'), require('fora-extensions').Loader);
    else
        define([], function() { return definition(React, ForaUI, ForaExtensions.Loader); });
}

loader(fn);

