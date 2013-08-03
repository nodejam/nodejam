modules = {
    users: 'Users',
    forums: 'Forums',
    posts: 'Posts',
    articles: 'Articles',
}

for k, v of modules
    exports[v] = require("./#{k}")[v]


