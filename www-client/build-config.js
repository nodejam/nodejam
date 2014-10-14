(function() {

    "use strict";

    var _;

    module.exports = function(tools) {

        var spawn = tools.process.spawn();
        var exec = tools.process.exec({ log: console.log });
        var ensureDirExists = tools.fs.ensureDirExists();
        var react = require('react-tools');
        var compressor = require('node-minify');
        var path = require('path');
        var fs = require('fs');

        var clientModules = ["fora-db", "fora-extensions-service", "fora-models", "fora-request"];
        var serverModules = ["fora-data-utils", "fora-router", "fora-types-service", "fora-validator"];
        var libModules = ["fora-app-ui", "fora-app-services", "fora-app-models", "fora-app-logger", "fora-app-renderer", "fora-app-sandbox",
                          "fora-app-client", "fora-app-types-service", "fora-app-initialize", "fora-app-randomizer"];

        return function() {

            var reactPages = [];
            var extensions = [];

            /*
                When the build starts, recreate the app directory
            */
            this.onStart(function*() {
                console.log("*****************************");
                console.log("Started fora/www-client build");
                console.log("*****************************");
                this.state.start = Date.now();
                _ = yield* exec("rm -rf app");
                _ = yield* exec("mkdir app");
            }, "client_build_start");


            /*
                Copy all files, except .less
            */
            this.watch(
                ["src/www/css/*.*", "src/www/fonts/*.*", "src/www/images/*.*",
                 "src/www/js/*.js", "src/www/vendor/*.*"],
                function*(filePath) {
                    if (!/(\.less$)/.test(path.extname(filePath))) {
                        var dest = filePath.replace(/^src\//, 'app/');
                        _ = yield* ensureDirExists(dest);
                        _ = yield* exec("cp " + filePath + " " + dest);
                    }
                },
                "client_files_copy"
            );


            /*
                Also watch ../server/node_modules
            */
            this.watch(
                serverModules.map(function(m) { return "../server/node_modules/" + m + "/*.*";}),
                function*(filePath) {
                    var dest = filePath.replace(/^\.\.\/shared\/node_modules\//, 'app/www/lib/');
                    _ = yield* ensureDirExists(dest);
                    _ = yield* exec("cp " + filePath + " " + dest);
                }
            );


            /*
                Compile less files. Schedule it at the end.
            */
            this.watch(["src/www/css/*.less"], function*(filePath) {
                _ = yield* ensureDirExists('app/www/css/main.css');
                this.queue(function*() {
                    _ = yield* exec("lessc --verbose src/www/css/main.less app/www/css/main.css");
                });
            }, "client_less_compile");


            /*
                1. Do facebook regenerator transform on all client side js files
                2. Browserify bundle
            */
            this.job(function*() {

                // var transformables = ["app/www/js/*.js"]
                // this.watch(transformables, function*(filePath) {
                //     //Skip regenerator in es6 mode. Requires flags in browsers (as of June 2014)
                //     if (!this.build.state.useES6) {
                //         var result = yield* exec("regenerator " + filePath);
                //         fs.writeFileSync(filePath, result);
                //     }

                extensions = extensions.filter(function(e) {
                    return /\/index\.json$|\/index\.js$/.test(e) &&
                        !/\/views\//.test(e);
                });

                console.log("Writing out app/www/js/extensions/extensions.json");
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
                    _ = yield* minify({
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
                    _ = yield* minify({
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

                var cmdMakeLib = "browserify " +
                     "-r ./app/www/vendor/js/shims/react.shim.js:react " +
                     "-r ./app/www/vendor/js/shims/co.shim.js:co " +
                     "-r ./app/www/vendor/js/shims/markdown.shim.js:markdown " +
                     "-r ./app/www/js/lib/path-to-regexp/path-to-regexp:path-to-regexp " +
                     serverModules.concat(clientModules).map(function(m) {
                         return "-r ./app/www/node_modules/" + m + "/" + m + ":" + m;
                     }).join(" ") + " " +
                     libModules.map(function(m) {
                         return "-r ./app/www/js/lib/" + m + "/" + m + ":" + m;
                     }).join(" ") + " " +
                     "> app/www/js/lib.js";

                var cmdMakeBundle = "browserify " +
                    "-x markdown -x react -x co " +
                    serverModules.concat(clientModules).concat(libModules).map(function(m) {
                        return "-x " + m;
                    }).join(" ") + " " +
                    reactPages.concat(extensions).map(function(x) {
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

                _ = yield* exec(cmdMakeLib);
                _ = yield* exec(cmdMakeBundle);


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
