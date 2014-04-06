index = function*(context) {
    forum = context.forum;
    posts = yield forum.getPosts(12, { "sort": { "_id": -1 }});
    posts.forEach(function*(post) {
        yield post.render();
    });
}


post = function*(context) {
    
}


about = function*(context) {

}


module.exports.init = function*(context) {
    context.pages.add("", index);
    context.pages.add(":post", post);
    context.pages.add("about", about);        
}




/*
exports.addRoutes = function(table) {
    table.add("/")
}

*/
