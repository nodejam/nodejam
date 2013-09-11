mdparser = require('../../../../../common/lib/markdownutil').marked

class Article
    render: (req, res, next, forum, post, user) =>
        res.render req.network.getView('postTypes', 'article'), { 
            post,
            user,
            forum,
            postJson: JSON.stringify(post),
            content: mdparser(post.content),
            pageName: 'post-page', 
            pageType: 'std-page', 
        }

exports.Article = Article
