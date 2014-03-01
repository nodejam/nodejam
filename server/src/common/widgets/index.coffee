modules = {
    page: 'page',
    cover: 'cover',
    heading: 'Heading',
    html: 'Html',
    author: 'Author',
    card: 'Card',
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

