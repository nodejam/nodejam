modules = {
    users: 'Users',
    forums: 'Forums',
    posts: 'Posts'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]


