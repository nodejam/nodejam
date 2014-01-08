modules = {
    article: 'Article',
    conversation: 'Conversation',
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

