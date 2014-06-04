(function() {
    "use strict"
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
                var fs = require('fs');
                this.state.start = Date.now(); //Note the time
                if(fs.existsSync('app')) {
                    yield exec("rm -rf app");
                }  
                yield exec("mkdir app");        
            }, "server_build_start");
            

            /*
                Compile all coffee-script files
                Coffee doesn't do coffee {src} {dest} yet, hence the redirection.
            */
            this.watch(["src/*.coffee"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/').replace(/\.coffee$/, '.js');
                yield ensureDirExists(dest);
                yield exec("coffee -cs < " + filePath + " > " + dest);
                this.build.queue('restart_server');
            }, "server_coffee_compile");


            /*
                Copy everything under setup
            */
            this.watch(["src/scripts/setup/*.md"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                yield ensureDirExists(dest);
                yield exec("cp " + filePath + " " + dest);
            }, "server_setup_data_copy");

            
                
            /*
                Watch everything under shared. Anything that moves, copy it.
            */
            this.watch(["../shared/app/*.*"], function*(filePath) {
                var dest = filePath.replace(/^\.\.\/shared\/app\//, 'app/')
                yield ensureDirExists(dest);
                yield exec("cp " + filePath + " " + dest);
                this.build.queue('restart_server');        
            }, "server_shared_files_copy");
            

            /*
                Copy config
            */
            this.watch(["src/conf/*.config"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                yield ensureDirExists(dest);
                yield exec("cp " + filePath + " " + dest);
                this.build.queue('restart_server');
            }, "server_conf_files_copy");
               

            /*
                Copy all hbs files
            */
            this.watch(["src/website/views/*.hbs"], function*(filePath) {
                var dest = filePath.replace(/^src\//, 'app/');
                yield ensureDirExists(dest);
                yield exec("cp " + filePath + " " + dest);
                this.build.queue('restart_server');
            }, "server_hbs_copy");
            
            /*
                if DEBUG, overwrite default.hbs with  default-debug.hbs
                Also note the time.
            */
            this.onComplete(function*() {        
                //Copy default-debug.hbs to default.hbs
                if (this.build.state.debug)
                    yield exec("cp src/website/views/layouts/default-debug.hbs app/website/views/layouts/default.hbs");
                this.state.end = Date.now();
            }, "server_build_complete");
            
        }    
    }
})();
