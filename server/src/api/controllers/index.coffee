modules = {
    users: 'Users',
    collections: 'Collections',
    records: 'Records'
    images: 'Images'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]


