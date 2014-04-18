/** @jsx ui.DOM */
var ui = require("fora-ui");
var Page = ui.controls.Page,
    Content = ui.controls.Content;

module.exports = ui.createClass({
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
