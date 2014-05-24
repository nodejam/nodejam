ForaUI = require('fora-ui');

index = function*() {
    var posts = yield this.forum.getPosts(12, { "sort": { "_id": -1 }});

    return yield ForaUI.helpers.renderForum({
        posts: posts,
        forumTemplate: 'index',
        postTemplate: 'list'
    }, this);
}


post = function*(stub) {
    post = yield this.forum.getPost(stub);
    
    return yield ForaUI.helpers.renderPost({
        post: post,
        forumTemplate: 'item',
        postTemplate: 'item'
    }, this);    
}


about = function*() {

}

module.exports.init = function*() {
    this.routes.pages.add("", index);
    this.routes.pages.add("about", about);        
    this.routes.pages.add(":post", post);
}

