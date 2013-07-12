modules = {
    session: 'Session',
    user: 'User',
    forum: 'Forum',
    post: 'Post',
    token: 'Token',
    userinfo: 'UserInfo',
    message: 'Message',
    network: 'Network',
    comment: 'Comment',
    article: 'Article'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

