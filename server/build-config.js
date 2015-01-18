(function() {
    "use strict";

    module.exports = function(tools) {

        var spawn = tools.process.spawn();
        var exec = tools.process.exec({ log: console.log });
        var ensureDirExists = tools.fs.ensureDirExists();
        var react = require('react-tools');

        var npmModules = ["ceramic", "ceramic-backend-mongodb", "ceramic-dictionary-parser", "ceramic"];

        return function() {

            /*
                When the build starts, recreate the app directory
            */
            this.onStart(function*() {
                console.log("*************************");
                console.log("Started fora/server build");
                console.log("*************************");
                var fs = require('fs');
                this.state.start = Date.now(); //Note the time
                if(fs.existsSync('app')) {
                    yield* exec("rm -rf app");
                }
                yield* exec("mkdir app");
            }, "server_build_start");


            /*
                Copy other files
            */
            this.watch(["src/*.config", "src/*.json", "src/*.js"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                yield* ensureDirExists(dest);
                yield* exec("cp " + filePath + " " + dest);
                this.build.queue('restart_server');
            }, "server_files_copy");


            /*
                Copy everything under setup
            */
            this.watch(["src/scripts/setup/*.md"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                yield* ensureDirExists(dest);
                yield* exec("cp " + filePath + " " + dest);
            }, "server_setup_data_copy");


            /*
                We have to reload the app when anything under node_modules change
            */
            this.watch(
                npmModules.map(function(m) { return "../node_modules/" + m + "/lib/*.*"; }),
                function*(filePath) {
                    this.build.queue('restart_server');
                },
                "server_modules_watch"
            );


            /*
                Compile all JSX files
                Use the React Tools API for this; there is no way to do this from the command line
            */
            this.watch(["src/lib/fora-lib-ui/*.jsx", "src/extensions/*.jsx"], function*(filePath) {
                var fs = require('fs');
                var dest = filePath.replace(/^src\//, 'app/').replace(/\.jsx$/, '.js');
                yield* ensureDirExists(dest);
                var contents = fs.readFileSync(filePath);
                console.log("jsx " + filePath);
                var result = react.transform(contents.toString());
                fs.writeFileSync(dest, result);
                this.build.queue('restart_server');
            }, "servier_jsx_compile");


            /*
                Note the time.
            */
            this.onComplete(function*() {
                this.state.end = Date.now();
            }, "server_build_complete");

        };
    };
})();
