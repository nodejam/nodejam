/** @jsx React.DOM */
fn = function(React, ForaUI, ExtensionLoader, Models) {
    var Page = ForaUI.Page,
        Content = ForaUI.Content;

    return React.createClass({
        render: function() {        
            createItem = function(forum) {
                if (forum.cover) {
                    style = {
                        backgroundImage: "url(" + forum.cover.image.small + ")"
                    };
                    image = <div className="image" style={style}></div>
                }
                else
                    image = null;
                    
                return (
                    <li className="col-span span5">
                        {image}
                        <article>
                            <h2><a href={"/" + forum.stub}>{forum.name}</a></h2>
                            <ul>
                                {
                                    forum.cache.posts.map(function(post) {
                                        return (
                                            <li>
                                                <a href={"/" + forum.stub + "/" + post.stub}>{post.title}</a><br />
                                                <span className="subtext">{post.createdBy.name}</span>
                                            </li>
                                        );
                                    })
                                }
                            </ul>
                        </article>
                    </li>
                );
            };    

            return (
                <Page>
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
                        <div className="content-area wide">
                            <ul className="articles card-view">
                                {this.props.forums.map(createItem)}     
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
        module.exports = definition(
            require('react'), 
            require('fora-ui'), 
            require('fora-extensions').Loader, 
            require('../../../models')
        );
    else
        define([], function() { return definition(React, ForaUI, ForaExtensions.Loader, Fora.Models); });
}

loader(fn);

