modules = {
    sessions: 'Sessions',
    forums: 'Forums',
    posts: 'Posts',
}

for k,v of modules
    exports[v] = require("./#{k}")[v]


