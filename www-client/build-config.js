(function() {

    "use strict";

    module.exports = function(tools) {

        var spawn = tools.process.spawn();
        var exec = tools.process.exec({ log: console.log });
        var ensureDirExists = tools.fs.ensureDirExists();
        var react = require('react-tools');
        var compressor = require('node-minify');
        var path = require('path');
        var fs = require('fs');

        var clientModules = ["fora-lib-db-backend", "fora-lib-extensions-service", "fora-lib-request"];
        var serverNpmModules = ["ceramic"];
        var libModules = ["fora-lib-ui", "fora-lib-services", "fora-lib-models", "fora-lib-logger", "fora-lib-renderer", "fora-lib-sandbox",
                          "fora-lib-types-service", "fora-lib-initialize", "fora-lib-randomizer", "fora-lib-db-connector", "fora-lib-data-utils",
                          "fora-lib-router"];

        var cmd_browserify = "../node_modules/.bin/browserify";
        var cmd_regenerator = "../node_modules/.bin/regenerator";
        var cmd_lessc = "../node_modules/.bin/lessc";

        return function() {

            var extensions = [];

            /*
                When the build starts, recreate the app directory
            */
            this.onStart(function*() {
                console.log("*****************************");
                console.log("Started fora/www-client build");
                console.log("*****************************");
                this.state.start = Date.now();
                yield* exec("rm -rf app");
                yield* exec("mkdir app");
            }, "client_build_start");


            /*
                Copy all files, except .less
            */
            this.watch(
                ["src/www/css/*.*", "src/www/fonts/*.*", "src/www/images/*.*",
                 "src/www/js/*.js", "src/www/vendor/*.*"],
                function*(filePath) {
                    var exlcudes = ["\\.less$", "\\.sh$"];
                    if (!exlcudes.some(function(ex) { return new RegExp(ex).test(path.extname(filePath)); })) {
                        var dest = filePath.replace(/^src\//, 'app/');
                        yield* ensureDirExists(dest);
                        yield* exec("cp " + filePath + " " + dest);
                    }
                },
                "client_files_copy"
            );

            /*
                Watch ../server/config
            */
            this.watch(
                ["../server/src/config/*.*"],
                function*(filePath) {
                    var dest = filePath.replace(/^\.\.\/server\/src\//, 'app/www/js/');
                    yield* ensureDirExists(dest);
                    yield* exec("cp " + filePath + " " + dest);
                },
                "client_server_config_copy"
            );


            /*
                Watch ../node_modules
            */
            this.watch(
                serverNpmModules.map(function(m) { return "../node_modules/" + m + "/*.*";}),
                function*(filePath) {
                    //We dont want anything inside .git dir and inner node_modules
                    var mustCopy = !/\/\.git\//.test(filePath) &&
                        (filePath.split('/').filter(function(x) { return x === "node_modules"; }).length <= 1);
                    if (mustCopy) {
                        var dest = filePath.replace(/^\.\.\/node_modules\//, 'app/www/js/lib/');
                        yield* ensureDirExists(dest);
                        yield* exec("cp " + filePath + " " + dest);
                    }
                },
                "client_server_npm_copy"
            );


            /*
                watch ../server/src/extensions/*.*
            */
            this.watch(
                ["../server/app/extensions/*.*"],
                function*(filePath) {
                    var dest = filePath.replace(/^\.\.\/server\/app\/extensions\//, 'app/www/js/extensions/');
                    yield* ensureDirExists(dest);
                    yield* exec("cp " + filePath + " " + dest);
                    extensions.push(dest);
                },
                "client_server_extensions_copy"
            );


            /*
                watch ../server/src/lib/*.js
            */
            this.watch(
                libModules.map(function(m) { return "../server/app/lib/" + m + "/*.*";}),
                function*(filePath) {
                    var dest = filePath.replace(/^\.\.\/server\/app\/lib\//, 'app/www/js/lib/');
                    yield* ensureDirExists(dest);
                    var parts = filePath.split("/");
                    if (parts[4] === "fora-lib-ui" || !fs.existsSync(dest))
                        yield* exec("cp " + filePath + " " + dest);
                    else
                        console.log("Skipping " + filePath + " -> " + dest);
                },
                "client_server_lib_copy",
                ["client_files_copy"]
            );



            /*
                Compile less files. Schedule it at the end.
            */
            var lessCompile = function*() { yield* exec(cmd_lessc + " --verbose src/www/css/main.less app/www/css/main.css"); };
            this.watch(["src/www/css/*.less"], function*(filePath) {
                yield* ensureDirExists('app/www/css/main.css');
                this.queue(lessCompile);
            }, "client_less_compile");


            /*
                Do regenerator transform, if not in es6 mode?
            */
            if (!this.build.state.useES6) {
                this.watch(
                    ["app/www/js/*.js"],
                    function*(filePath) {
                        var result = yield* exec(cmd_regenerator + " " + filePath);
                        fs.writeFileSync(filePath, result);
                    },
                    "client_regenerator_transform",
                    [
                        "client_files_copy", "client_server_npm_copy", "client_server_lib_copy",
                        "client_server_config_copy", "client_server_extensions_copy"
                    ]
                );
            }


            /*
                Hook the bundle step
            */
            var bundleTrigger = this.build.state.useES6 ?
                ["client_files_copy", "client_server_npm_copy", "client_server_lib_copy", "client_server_config_copy", "client_server_extensions_copy"]
                : ['client_regenerator_transform'];

            this.watch(["app/www/js/*.js"], function*(filePath) {
                this.queue("client_bundle_files");
            }, "client_bundle_hook", bundleTrigger);



            /*
                1. Do facebook regenerator transform on all client side js files
                2. Browserify bundle
            */
            this.job(function*() {
                extensions = extensions.filter(function(e) {
                    var parts = e.split("/");
                    return ["model", "definition", "web"].indexOf(parts[7]) > -1 &&
                        ["index.js", "index.json"].indexOf(parts[8]) > -1;
                });

                console.log("Writing out app/www/js/extensions/extensions.json");
                yield* ensureDirExists("app/www/js/extensions/extensions.json");
                fs.writeFileSync("app/www/js/extensions/extensions.json", JSON.stringify(
                    extensions.map(function(e) {
                        return e.replace(/\/index\.json$|\/index\.js$/, '')
                             .replace(/\.json$|\.js$/, '')
                             .replace(/^app\/www\/js\//,'/');
                    })
                ));

                if (!this.build.state.debugClient) {
                    var minify = function*(options) {
                        yield function(options) {
                            return function(cb) {
                                options.callback = cb;
                                new compressor.minify(options);
                            };
                        }(options);
                    };

                    console.log("Minifying CSS to lib.css");
                    yield* minify({
                        type: 'sqwish',
                        buffer: 1000 * 1024,
                        tempPath: '../temp/',
                        fileIn: [
                            'app/www/vendor/components/font-awesome/css/font-awesome.css',
                            'app/www/vendor/css/HINT.css',
                            'app/www/vendor/css/toggle-switch.css',
                            'app/www/vendor/components/medium-editor/css/medium-editor.css',
                            'app/www/vendor/components/medium-editor/css/themes/default.css',
                        ],
                        fileOut: 'app/www/css/lib.css'
                    });

                    console.log("Minifying JS to vendor.js");
                    yield* minify({
                        type: 'no-compress',
                        buffer: 1000 * 2048,
                        tempPath: '../temp/',
                        fileIn: [
                            'app/www/vendor/js/co.js',
                            'app/www/vendor/js/markdown.min.js',
                            'app/www/vendor/js/setImmediate.js',
                            'app/www/vendor/js/regenerator-runtime.js',
                            'app/www/vendor/js/react.min.js'
                        ],
                        fileOut: 'app/www/js/vendor.js'
                    });
                }

                console.log("Running browserify");

                var cmdMakeLib = cmd_browserify + " " +
                     "-r ./app/www/vendor/js/shims/react.shim.js:react " +
                     "-r ./app/www/js/lib/jayschema:jayschema " +
                     "-r ./app/www/vendor/js/shims/co.shim.js:co " +
                     "-r ./app/www/vendor/js/shims/markdown.shim.js:markdown " +
                     "-r ./app/www/js/lib/path-to-regexp:path-to-regexp " +
                     "-x jayschema " +
                     serverNpmModules.map(function(m) {
                         return "-r ./app/www/js/lib/" + m + "/lib/" + m + ":" + m;
                     }).join(" ") + " " +
                     libModules.concat(clientModules).map(function(m) {
                         return "-r ./app/www/js/lib/" + m + ":" + m;
                     }).join(" ") + " " +
                     "> app/www/js/lib.js";

                var cmdMakeBundle = cmd_browserify + " " +
                    " -x react -x co -x path-to-regexp -x jayschema -x markdown " +
                    serverNpmModules.concat(clientModules).concat(libModules).map(function(m) {
                        return "-x " + m;
                    }).join(" ") + " " +
                    extensions.map(function(x) {
                        //Take out .js, .json, /index.js and /index.json since require doesn't need it
                        var dest = x.replace(/\/index\.json$|\/index\.js$/, '').replace(/\.json$|\.js$/, '');
                        return "-r ./" + x + ":" + dest.replace(/^app\/www\/js\//,'/');
                    }).join(" ") + " " +
                    "-r ./app/www/js/extensions/extensions.json:/extensions/models " +
                    "./app/www/js/app " +
                    "> app/www/js/bundle.js";

                if (this.build.state.debugClient) {
                    cmdMakeLib += " --debug";
                    cmdMakeBundle += " --debug";
                }

                yield* exec(cmdMakeLib);
                yield* exec(cmdMakeBundle);


            }, "client_bundle_files");


            /*
                If debug, include all unminified js files. Otherwise minify.
                Finally, go back and change debug.hbs
            */
            this.onComplete(function*() {
                this.state.end = Date.now();
            }, "client_build_complete");
        };
    };
})();
