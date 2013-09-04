modules = {
    user: 'User',
    credentials: 'Credentials',
    forum: 'Forum',
    post: 'Post',
    token: 'Token',
    userinfo: 'UserInfo',
    message: 'Message',
    network: 'Network',
    comment: 'Comment',
    article: 'Article',
    membership: 'Membership',
    extendedfield: 'ExtendedField',
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

exports.DbContext = require('./appmodels').DbContext
