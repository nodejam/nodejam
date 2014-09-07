(function() {
    "use strict";

    var _;

    module.exports = function(tools) {

        var spawn = tools.process.spawn();
        var exec = tools.process.exec({ log: console.log });
        var ensureDirExists = tools.fs.ensureDirExists();
        var react = require('react-tools');

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
                    _ = yield* exec("rm -rf app");
                }
                _ = yield* exec("mkdir app");
            }, "server_build_start");


            /*
                Copy other files
            */
            this.watch(["src/*.config", "src/*.json", "src/*.js"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                _ = yield* ensureDirExists(dest);
                _ = yield* exec("cp " + filePath + " " + dest);
                this.build.queue('restart_server');
            }, "server_files_copy");


            /*
                Copy everything under setup
            */
            this.watch(["src/scripts/setup/*.md"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                _ = yield* ensureDirExists(dest);
                _ = yield* exec("cp " + filePath + " " + dest);
            }, "server_setup_data_copy");



            /*
                Watch everything under shared. Anything that moves, copy it.
            */
            this.watch(["../shared/app/*.*"], function*(filePath) {
                var dest = filePath.replace(/^\.\.\/shared\/app\//, 'app/');
                _ = yield* ensureDirExists(dest);
                _ = yield* exec("cp " + filePath + " " + dest);
                this.build.queue('restart_server');
            }, "server_shared_files_copy");


            /*
                Note the time.
            */
            this.onComplete(function*() {
                this.state.end = Date.now();
            }, "server_build_complete");

        };
    };
})();
