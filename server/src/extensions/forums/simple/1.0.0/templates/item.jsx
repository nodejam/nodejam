/** @jsx React.DOM */
fn = function(React, ForaUI, ExtensionLoader, Models) {
    var Page = ForaUI.Page,
        Content = ForaUI.Content,
        Cover = ForaUI.Cover;

    var loader = new ExtensionLoader();
        
    return React.createClass({
        statics: {
            componentInit: function*(component, isBrowser) {           
                /* Convert the JSON into Post objects and attach the templates */
                if (isBrowser)
                    component.props.post = new Models.Post(component.props.post);
                extension = yield loader.load(yield component.props.post.getTypeDefinition());
                component.props.post.template = yield extension.getTemplateModule(component.props.postTemplate);
            }
        },
            
        render: function() {
            return (
                <Page cover={this.props.post.cover}>
                    <Cover cover={this.props.post.cover} />                
                    <Content>            
                        <div className="content-area item">
                            {
                                this.props.post.template({
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
        module.exports = definition(
            require('react'), 
            require('fora-ui'), 
            require('fora-extensions').Loader, 
            require('../../../../../models')
        );
    else
        define([], function() { return definition(React, ForaUI, ForaExtensions.Loader, Fora.Models); });
}

loader(fn);

