mdparser = require('../../../../common/lib/markdownutil').marked

class Article

    render: (req, res, next, params) =>
        res.render req.network.getView('posttypes', 'article'), { 
            post: params.post,
            author: params.author,
            user: params.user,
            forum: params.forum,
            editable: params.editable,
            postJson: JSON.stringify(params.post),
            content: mdparser(params.post.content),
            pageName: 'post-page', 
            pageType: 'std-page', 
        }

exports.Article = Article
