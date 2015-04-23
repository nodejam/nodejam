let loadDefaults = function(source, destination) {
    return {
        "dir-custom-tasks": { "value": "_custom_tasks", "replace": true },
        "dir-client-build": { "value": "_js", "replace": true },
        "dir-dev-build": { "value": "_dev_js", "replace": true },
        "dirs-client-vendor": { "value": ["_vendor"], "replace": true },
        "jekyll": {
            //Directories
            "dirs-includes": ["_includes"],
            "dirs-layouts": ["_layouts"],
            "dir-fora": "-fora",

            //Handling Reading
            "markdown-ext": ["markdown","mkdown","mkdn","mkd","md"],
            "encoding": "utf-8",

            //Serving
            "dirs-static-files": { "value": ["js", "vendor", "css", "images", "fonts"], "replace": true },

            //Conversion
            "excerpt-separator": "\n\n",

            //Filtering Content
            "show-drafts": false,
            "limit-posts": 0,
            "future": false,
            "unpublished": false,

            //Outputting
            "permalink": "date",
            "paginate-path": "/page:num",
            "timezone": null,
        },
        "tasks": {
            "load-data": {
                "dirs-data": { "value": ["-data"], "replace": true },
                "markdown-ext": { "value": ["markdown","mkdown","mkdn","mkd","md"], "replace": true }
            },
            "less": {
                "dirs": { "value": ["-css"], "replace": true }
            },
            "copy-static-files": {
                "skip-extensions": { value: ["markdown","mkdown","mkdn","mkd","md", "yml", "yaml", "less", "json"], "replace": true }
            }
        },

        "collections": {
            "posts": { "dir": "-posts", "output": true },
            "pages": { "output": true }
        },

        "scavenge-collection": "pages"
    };
};

export default { loadDefaults };
