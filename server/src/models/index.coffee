modules = {
    user: 'User',
    credentials: 'Credentials',
    collection: 'Collection',
    record: 'Record',
    token: 'Token',
    userinfo: 'UserInfo',
    message: 'Message',
    network: 'Network',
    comment: 'Comment',
    article: 'Article',
    membership: 'Membership'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

