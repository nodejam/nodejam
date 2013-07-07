modules = {
    sessions: 'Sessions',
    forums: 'Forums',
    articles: 'Articles',
}

for k, v of modules
    exports[v] = require("./#{k}")[v]


