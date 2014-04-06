index = function*(context) {
    var forum = context.forum;
    var posts = yield forum.getPosts(12, { "sort": { "_id": -1 }});
    posts.forEach(function*(post) {
        post.html = yield post.render('card', { forum: post.forum, author: post.createdBy });
    });
    
    var options = {};
    
    if (this.session.user) {
        var membership = yield forum.getMembership(this.session.user.username);
        if (membership)
            options.isMember = true;
    }
        
    var coverContent = " \
        <h1>#{forum.name}</h1> \
        <p data-field-type=\"plain-text\" data-field-name=\"description\">#{forum.description}</p> \
        <div class=\"option-bar\"><button class=\"edit\">Edit</button></div>"
        
    if (!forum.cover) {
        forum.cover = new fields.Cover({ 
            image: new fields.Image({ 
                src: '/images/forum-cover.jpg', 
                small: '/images/forum-cover-small.jpg', 
                alt: forum.name
            })
        });
    }
     
    yield this.renderPage('forums/item', { 
        forum: forum,
        forumJson: JSON.stringify(forum),
        message: forum.message ? mdparser(forum.message) : "",
        posts: posts, 
        options: options,
        pageName: 'forum-page', 
        coverInfo: {
            cover: forum.cover,
            content: coverContent
        }
    });    
}


post = function*(context, stub) {
    forum = yield context.getForum();
    post = yield forum.getPost(stub);
    author = yield post.getAuthor();
    typeDefinition = yield post.getTypeDefinition();
    
    extension = yield context.getExtension(post);
    template = yield extension.getTemplate('item');
    component = template({ post: post, forum: forum, author: author, typeDefinition: typeDefinition });
    return React.renderComponentToString(component);
}


about = function*(context) {

}


module.exports.init = function*(context) {
    context.pages.add("", index);
    context.pages.add("about", about);        
    context.pages.add(":post", post);
    return
}

