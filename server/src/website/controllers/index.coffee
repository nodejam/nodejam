modules = {
    auth: 'Auth',
    users: 'Users',
    home: 'Home',
    collections: 'Collections',
    records: 'Records'
}

for k,v of modules
    exports[v] = require("./#{k}")[v]


