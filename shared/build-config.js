(function() {
    "use strict";

    var _;

    module.exports = function(tools) {

        var spawn = tools.process.spawn();
        var exec = tools.process.exec({ log: console.log });
        var ensureDirExists = tools.fs.ensureDirExists();
        var react = require('react-tools');
        var compressor = require('node-minify');

        return function() {

            /*
                When the build starts, recreate the app directory
            */
            this.onStart(function*() {
                console.log("*************************");
                console.log("Started fora/shared build");
                console.log("*************************");
                this.state.start = Date.now();
                yield* exec("rm -rf app");
                yield* exec("mkdir app");
            }, "shared_build_start");



            /*
                Compile all JSX files
                Use the React Tools API for this; there is no way to do this from the command line
            */
            this.watch(["src/extensions/*.jsx", "src/lib/fora-app-ui/*.jsx"], function*(filePath) {
                var fs = require('fs');
                var dest = filePath.replace(/^src\//, 'app/').replace(/\.jsx$/, '.js');
                yield* ensureDirExists(dest);
                var contents = fs.readFileSync(filePath);
                console.log("jsx " + filePath);
                var result = react.transform(contents.toString());
                fs.writeFileSync(dest, result);
            }, "shared_jsx_compile");


            /*
                Copy other files
            */
            this.watch(["src/*.json", "src/*.js"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                yield* ensureDirExists(dest);
                yield* exec("cp " + filePath + " " + dest);
            }, "shared_files_copy");


            /*
                If debug, include all unminified js files. Otherwise minify.
                Finally, go back and change debug.hbs
            */
            this.onComplete(function*() {
                this.state.end = Date.now();
            }, "shared_build_complete");
        };
    };
})();
