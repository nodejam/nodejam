modules = {
    page: 'Page',
    cover: 'Cover',
    heading: 'Heading',
    text: 'Text',
    author: 'Author',
    card: 'Card',
    post: 'Post',
    forum: 'Forum',
    item: 'Item',
    content: 'Content'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

exports.helpers = require('./helpers')
