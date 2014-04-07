modules = {
    page: 'Page',
    cover: 'Cover',
    heading: 'Heading',
    html: 'Html',
    text: 'Text',
    author: 'Author',
    card: 'Card'
}

for k, v of modules
    exports[v] = require("./#{k}")[v]

