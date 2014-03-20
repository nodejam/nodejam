pages = require("./pages")

module.exports = function(context) {
    context.pages.add("", pages.index);
    context.pages.add(":post", pages.post);
    context.pages.add("about", pages.about);
}

