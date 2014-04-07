w = require('widgets');
indexTemplate = require('./templates/index');

index = function*() {
    forum = this.forum;
    var posts = yield forum.getPosts(12, { "sort": { "_id": -1 }});

    for (i = 0; i < posts.length; i++) {
        extensions = yield this.api.extensionLoader.load(yield posts[i].getTypeDefinition());
        posts[i].template = yield extensions.getTemplate('card');
    }
        
    var options = {};
    if (this.context.session) {
        var membership = yield forum.getMembership(this.context.session.user.username);
        if (membership)
            options.isMember = true;
    }

    component = indexTemplate({ posts: posts, forum: forum, options: options });
    return React.renderComponentToString(component);
}


post = function*(stub) {
    forum = yield this.getForum();
    post = yield forum.getPost(stub);
    author = yield post.getAuthor();
    typeDefinition = yield post.getTypeDefinition();
    
    extension = yield this.getExtension(post);
    template = yield extension.getTemplate('item');
    component = template({ post: post, forum: forum, author: author, typeDefinition: typeDefinition });
    return React.renderComponentToString(component);
}


about = function*() {

}

module.exports.init = function*() {
    this.pages.add("", index);
    this.pages.add("about", about);        
    this.pages.add(":post", post);
}

