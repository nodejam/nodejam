modules = {
    users: 'Users',
    collections: 'Collections',
    records: 'Records'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]


