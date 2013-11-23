modules = {
    users: 'Users',
    forums: 'Forums',
    posts: 'Posts'
    images: 'Images'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]


