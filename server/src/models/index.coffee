modules = {
    credential: 'Credential',
    user: 'User',
    session: 'Session',
    forum: 'Forum',
    foruminfo: 'ForumInfo',
    post: 'Post',
    token: 'Token',
    userinfo: 'UserInfo',
    message: 'Message',
    network: 'Network',
    membership: 'Membership',
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

