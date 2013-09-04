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
    attachment: 'Attachment'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

