React = require('react');
ForaUI = require('fora-ui');

IndexView = require('./templates/index').IndexView;
ItemView = require('./templates/item').ItemView;

index = function*() {
    var posts = yield this.forum.getPosts(12, { "sort": { "_id": -1 }});

    return yield ForaUI.helpers.renderForum({
        template: IndexView,
        forum: this.forum,
        posts: posts,
        postTemplateFile: 'list',
        postTemplateName: 'List'
    }, this);
}


post = function*(stub) {
    post = yield this.forum.getPost(stub);
    
    return yield ForaUI.helpers.renderPost({
        template: ItemView,
        post: post,
        forum: this.forum,
        postTemplateFile: 'item',
        postTemplateName: 'Item'
    }, this);    
}


about = function*() {

}

module.exports.init = function*() {
    this.pages.add("", index);
    this.pages.add("about", about);        
    this.pages.add(":post", post);
}

