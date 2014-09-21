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
                yield* exec("rm -rf app");
                yield* exec("mkdir app");
            }, "client_build_start");


            /*
                Copy all files, except .less
            */
            this.watch(["src/www/css/*.*", "src/www/fonts/*.*", "src/www/images/*.*", "src/www/js/*.js", "src/www/vendor/*.*"], function*(filePath) {
                if (!/(\.less$)/.test(path.extname(filePath))) {
                    var dest = filePath.replace(/^src\//, 'app/');
                    yield* ensureDirExists(dest);
                    yield* exec("cp " + filePath + " " + dest);
                }
            }, "client_files_copy");


            /*
                Watch everything under shared. Anything that moves, copy it.
            */
            this.watch(["../shared/app/*.*"], function*(filePath) {
                var dest = filePath.replace(/^\.\.\/shared\/app\//, 'app/www/js/')
                if (/^app\/www\/js\/website\/views\//.test(dest)) reactPages.push(dest);
                if (/^app\/www\/js\/extensions\//.test(dest)) extensions.push(dest);
                yield* ensureDirExists(dest);
                yield* exec("cp " + filePath + " " + dest);
            }, "client_shared_files_copy");


            /*
                Do facebook regenerator transform on all client side js files
            */
            this.watch(["app/www/js/*.js"], function*(filePath) {
                //Skip regenerator in es6 mode. Requires flags in browsers (as of June 2014)
                if (!this.build.state.useES6) {
                    var result = yield* exec("regenerator " + filePath);
                    fs.writeFileSync(filePath, result);
                }
            }, "client_regenerator_transform", ["client_shared_files_copy"]);


            /*
                Compile less files. Schedule it at the end.
            */
            this.watch(["src/www/css/*.less"], function*(filePath) {
                yield* ensureDirExists('app/www/css/main.css');
                if (!this.state.lesscQueued) {
                    this.state.lesscQueued = true;
                    this.queue(function*() {
                        yield* exec("lessc --verbose src/www/css/main.less app/www/css/main.css");
                    });
                }
            }, "client_less_compile");


            /*
                Bundle all files.
            */
            this.onComplete(function*() {

                console.log("Writing out app/www/js/extensions/models.js");
                fs.writeFileSync("app/www/js/extensions/models.json", JSON.stringify(
                    extensions.filter(function(e) { return /model\.js$/.test(e); })
                        .map(function(e) { return e.match(/(.*)\.js/)[1].replace(/^app\/www\//,'/'); })
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

                var cmdMakeLib = "browserify -r ./app/www/vendor/js/shims/react.shim.js:react -r ./app/www/vendor/js/shims/co.shim.js:co " +
                     "-r ./app/www/vendor/js/shims/markdown.shim.js:markdown " +
                     "-r ./app/www/js/lib/fora-extensions-service/fora-extensions-service:fora-extensions-service " +
                     "-r ./app/www/js/lib/fora-models/fora-models:fora-models " +
                     "-r ./app/www/js/lib/fora-router/lib/fora-router:fora-router " +
                     "-r ./app/www/js/lib/fora-app-ui:fora-app-ui " +
                     "-r ./app/www/js/lib/fora-app-type-helpers:fora-app-type-helpers " +
                     "-r ./app/www/js/lib/fora-app-services:fora-app-services " +
                     "-r ./app/www/js/lib/fora-app-models:fora-app-models " +
                     "-r ./app/www/js/lib/path-to-regexp/path-to-regexp:path-to-regexp " +
                     "-r ./app/www/js/lib/fora-app-logger:fora-app-logger " +
                     "-r ./app/www/js/lib/fora-app-renderer:fora-app-renderer " +
                     "-r ./app/www/js/lib/fora-app-sandbox:fora-app-sandbox " +
                     "-r ./app/www/js/lib/fora-request/fora-request:fora-request " +
                     "> app/www/js/lib.js";
                var cmdMakeBundle = "browserify " +
                    "-x markdown -x react -x co " +
                    "-x fora-extensions-service -x fora-app-renderer " +
                    "-x fora-models -x fora-router -x fora-app-ui " +
                    " -x fora-app-type-helpers -x fora-app-logger " +
                    "-x fora-app-services -x fora-app-models " +
                    "-x fora-app-sandbox " +
                    "./app/www/js/container/app " +
                    reactPages.concat(extensions).map(function(x) {
                        //Take out .js, .json, /index.js and /index.json since require doesn't need it
                        //x = x.replace(/\/index\.json$|\/index\.js$/, '').replace(/\.json$|\.js$/, '');
                        var dest = x.replace(/\/index\.json$|\/index\.js$/, '').replace(/\.json$|\.js$/, '');
                        return "-r ./" + x + ":" + dest.replace(/^app\/www\//,'/');
                    }).join(" ") +
                    " > app/www/js/bundle.js";

                if (this.build.state.debugClient) {
                    cmdMakeLib += " --debug";
                    cmdMakeBundle += " --debug";
                }

                yield* exec(cmdMakeLib);
                yield* exec(cmdMakeBundle)


            }, "client_bundle_files");


            /*
                If debug, include all unminified js files. Otherwise minify.
                Finally, go back and change debug.hbs
            */
            this.onComplete(function*() {
                this.state.end = Date.now();
            }, "client_build_complete", ["client_bundle_files"]);
        };
    };
})();
