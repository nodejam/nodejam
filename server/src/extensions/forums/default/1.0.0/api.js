module.exports = {
    router: function(routes) {
        routes.add("", "index");
        routes.about("", "about");
    },

    index: function(context) {
        forum = context.forum;
        posts = yield forum.getPosts(12, { "sort": { "_id": -1 }});
        for post in posts
        context.render()
    }    
}
