let loadDefaults = function(source, destination) {
    return {
        "source": source,
        "destination": destination,

        //Build customization
        "custom-builds-dir": "custom-builds",
        "custom-tasks-dir": "custom-tasks",

        //Exclude these patterns
        "excluded-dirs": [".git", "node_modules"],
        "excluded-patterns": [
            { "exclude": "file", "regex": "\.gitignore" }
        ],

        "js-extensions": ["js", "jsx"],
        "change-extensions": [{ to: "js", from: ["jsx"] }],

        //build
        "build-name": "client-debug",

        //static data and collections
        "collections": {},
        "collections-root-dir": "",
        "data-dirs": ["data"],

        //Handling Reading
        "watch": true,

        //Serving
        "detach": false,
        "port": 4000,
        "host": "127.0.0.1",
        "baseurl": "",
        "serve-static": "true",

        //Outputting
        "beautify": true, //beautify html output?

        //Make too much noise while processing?
        "quiet": false,

        "builds": {
            "client-debug": {
                "browser-build-file-suffix": "~client"
            },
            "dev": {
                "browser-build-file-suffix": "~dev"
            }
        }
    };
};

export default { loadDefaults };
