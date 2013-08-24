modules = {
    auth: 'Auth',
    home: 'Home',
    forums: 'Forums',
    users: 'Users',
    articles: 'Articles',
}

for k,v of modules
    exports[v] = require("./#{k}")[v]


