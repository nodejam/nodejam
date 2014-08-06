(function() {
    "use strict";
    module.exports = function(tools) {

        var spawn = tools.process.spawn({ log: function(data) { process.stdout.write(data); } });
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
                this.state.start = Date.now(); //Note the time
            }, "server_build_start");


            /*
                Copy other files
            */
            this.watch(["app/*.config", "app/*.json", "app/*.js"], function*(filePath) {
                this.build.queue('restart_server');
            }, "server_files_copy");



            /*
                Watch everything under shared. Anything that moves, copy it.
            */
            this.watch(["../shared/app/*.*"], function*(filePath) {
                var dest = filePath.replace(/^\.\.\/shared\/app\//, 'app/')
                yield* ensureDirExists(dest);
                yield* exec("cp " + filePath + " " + dest);
                this.build.queue('restart_server');
            }, "server_shared_files_copy");


            /*
                Note the time.
            */
            this.onComplete(function*() {
                this.state.end = Date.now();
            }, "server_build_complete");

        }
    }
})();
