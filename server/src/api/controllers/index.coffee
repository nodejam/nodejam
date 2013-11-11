modules = {
    users: 'Users',
    forums: 'Forums',
    records: 'Records'
    images: 'Images'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]


