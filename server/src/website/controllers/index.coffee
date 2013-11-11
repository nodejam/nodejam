modules = {
    auth: 'Auth',
    users: 'Users',
    home: 'Home',
    forums: 'Forums',
    records: 'Records'
}

for k,v of modules
    exports[v] = require("./#{k}")[v]


