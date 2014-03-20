module.exports.index = function(context) {
    forum = context.forum;
    posts = yield forum.getPosts(12, { "sort": { "_id": -1 }});
    for post in posts
        context.render()
}

module.exports.post = function(context) {

}

module.exports.about = function(context) {

}

/*
exports.addRoutes = function(table) {
    table.add("/")
}

exports.item = function() {
    forum = yield api.getForum()
    posts = yield forum.getPosts 12, { sort: "_id, desc" }
    user = yield 
    
    db.setRowId({}, -1))
    
    

    forum = yield models.Forum.get({ stub, network: @network.stub }, {}, db)
    info = yield forum.link 'info'

    if forum
        posts = yield forum.getPosts(12, db.setRowId({}, -1))

        for post in posts
            post.html = yield models.Post.render 'card', { post, forum: post.forum, author: post.createdBy }

        options = {}
        if @session.user
            membership = yield models.Membership.get { 'forum.id': db.getRowId(forum), 'user.username': @session.user.username }, {}, db
            if membership
                options.isMember = true
        
        coverContent = "
            <h1>#{forum.name}</h1>
            <p data-field-type=\"plain-text\" data-field-name=\"description\">#{forum.description}</p>
            <div class=\"option-bar\"><button class=\"edit\">Edit</button></div>"
            
        forum.cover ?= new fields.Cover { image: new fields.Image { src: '/images/forum-cover.jpg', small: '/images/forum-cover-small.jpg', alt: forum.name } }
        
        yield @renderPage 'forums/item', { 
            forum,
            forumJson: JSON.stringify(forum),
            message: if info.message then mdparser(info.message),
            posts, 
            options,
            pageName: 'forum-page', 
            coverInfo: {
                cover: forum.cover,
                content: coverContent
            }
        }
    
}
*/
