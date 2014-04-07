homeTemplate = require('./templates/home');

index = function*() {
    forum = this.forum;
    var posts = yield forum.getPosts(12, { "sort": { "_id": -1 }});
    posts.forEach(function*(post) {
        post.html = yield post.render('card', { forum: post.forum, author: post.createdBy });
    });
    
    var options = {};
    
    if (this.context.session) {
        var membership = yield forum.getMembership(this.context.session.user.username);
        if (membership)
            options.isMember = true;
    }
    
    component = homeTemplate({ posts: posts, forum: forum });
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

