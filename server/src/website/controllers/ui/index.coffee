modules = {
    auth: 'Auth',
    home: 'Home',
    forums: 'Forums',
    users: 'Users',
    dev_designs: 'Dev_Designs'
}

for k,v of modules
    exports[v] = require("./#{k}")[v]


