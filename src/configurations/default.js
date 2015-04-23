let loadDefaults = function(source, destination) {
    return {
        "source": source,
        "destination": destination,

        //Build customization
        "dir-custom-builds": "custom-builds",
        "dir-custom-tasks": "custom-tasks",

        "dirs-client-vendor": ["vendor"],

        //Exclude these patterns
        "dirs-exclude": [".git", "node_modules"],
        "patterns-exclude": [
            { "exclude": "file", "regex": "\.gitignore" }
        ],

        //build
        "build-name": "client-debug",
        "dir-client-build": "js",
        "client-js-suffix": "~client",
        "client-bundle-name": "app.bundle.js",

        "build-dev": true,
        "dir-dev-build": "dev-js",
        "dev-js-suffix": "~dev",
        "dev-bundle-name": "dev.bundle.js",

        //original file replaced by *~client.js and *~dev.js will be renamed to *-base.js
        "original-js-suffix": "_base",

        //static data and collections
        "collections": {},
        "collections-root-dir": "",
        "data-directories": ["data"],

        "app-entry-point": "app.js",
        "js-extensions": ["js", "jsx"],

        //Handling Reading
        "watch": true,

        //Serving
        "detach": false,
        "port": 4000,
        "host": "127.0.0.1",
        "baseurl": "",
        "serve-static": "true",
        "dirs-static-files": ["js", "vendor", "css", "images", "fonts"],

        //Outputting
        "beautify": true, //beautify html output?

        //Make too much noise while processing?
        "quiet": false,

        "builds": {
            "production": {
                "disabled-tasks": [],
                "tasks": {
                    "server-transpile": {
                        "blacklist": ["regenerator"]
                    },
                    "less": {
                        "dirs": ["css"]
                    },
                    "copy-static-files": {
                        "skip-extensions": ["less"]
                    },
                    "build-client": {},
                    "write-config": {
                        "filename": "config.json"
                    }
                }
            }
        }
    };
};

export default { loadDefaults };
