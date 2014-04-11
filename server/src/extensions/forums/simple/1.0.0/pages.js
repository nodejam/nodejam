IndexView = require('./templates/index');
PostView = require('./templates/post');
React = require('react');
controls = require('controls');

index = function*() {
    var posts = yield this.forum.getPosts(12, { "sort": { "_id": -1 }});

    return yield controls.helpers.renderForum({
        template: IndexView,
        forum: this.forum,
        posts: posts,
        postTemplate: 'card'
    }, this);
}


post = function*(stub) {
    post = yield this.forum.getPost(stub);
    
    return yield controls.helpers.renderPost({
        template: PostView,
        post: post,
        forum: this.forum,
        postTemplate: 'item'
    }, this);    
}


about = function*() {

}

module.exports.init = function*() {
    this.pages.add("", index);
    this.pages.add("about", about);        
    this.pages.add(":post", post);
}

