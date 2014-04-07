index = function*() {
    throw new Error("UNIMPLEMENTED")
    posts = yield this.forum.getPosts(12, { "sort": { "_id": -1 }});
    posts.forEach(function*(post) {
        yield post.render();
    });
}


module.exports.init = function*() {
    this.pages.add("", index);
}




/*
exports.addRoutes = function(table) {
    table.add("/")
}

*/
