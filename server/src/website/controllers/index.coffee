modules = {
    auth: 'Auth',
    users: 'Users',
    home: 'Home',
    forums: 'Forums',
    posts: 'Posts'
}

for k,v of modules
    exports[v] = require("./#{k}")[v]


