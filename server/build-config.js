co = require('co');
thunkify = require('thunkify');
fs = require('fs');
path = require('path');
argv = require('optimist').argv;

spawn = require('child_process').spawn;
_exec = require('child_process').exec
exec = thunkify(function(cmd, cb) {
    _exec(cmd, function(err, stdout, stderr) {
        cb(err, stdout.substring(0, stdout.length - 1));
    });
});

react = require('react-tools');

module.exports = function() {
    /*
        App restart job. 
        When files on the server change, a restart is necessary.
    */
    this.job(function*() {
        if (!argv.client && !argv.server && !argv.norun && this.build.monitoring) {
            console.log("Restarting the server.....");
            var script = spawn("sh", ["run.sh"]);
            script.stdout.on('data', function (data) {
              console.log(data.toString());
            });
        }
    }, "restart_server");


    /*
        Make sure directory exists for path
    */
    ensureDirExists = function*(file) {
        var dir = path.dirname(file);
        if (!fs.existsSync(dir)) {
            yield exec("mkdir -p " + dir);
        } 
    }
    

    /*
        When the build starts, recreate the app directory
    */
    this.onBuildStart(function*() {
        console.log("*************************");
        console.log("Started fora/server build");
        console.log("*************************");
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
        this.queue('restart_server');
    }, "server_coffee_compile");

        
    /*
        Watch everything under shared. Anything that moves, copy it.
    */
    this.watch(["../shared/app/*.*"], function*(filePath) {
        var dest = filePath.replace(/^\.\.\/shared\/app\//, 'app/')
        yield ensureDirExists(dest);
        yield exec("cp " + filePath + " " + dest);
        this.queue('restart_server');        
    }, "server_shared_files_copy");
    

    /*
        Copy config
    */
    this.watch(["src/conf/*.config"], function*(filePath) {
        var dest = filePath.replace(/^src\//, 'app/');
        yield ensureDirExists(dest);
        yield exec("cp " + filePath + " " + dest);
        this.queue('restart_server');
    }, "server_conf_files_copy");
       

    /*
        Copy all hbs files
    */
    this.watch(["src/website/views/*.hbs"], function*(filePath) {
        var dest = filePath.replace(/^src\//, 'app/');
        yield ensureDirExists(dest);
        yield exec("cp " + filePath + " " + dest);
        this.queue('restart_server');
    }, "server_hbs_copy");
    
    /*
        if DEBUG, overwrite default.hbs with  default-debug.hbs
        Also note the time.
    */
    this.onBuildComplete(function*() {        
        //Copy default-debug.hbs to default.hbs
        yield exec("cp src/website/views/layouts/default-debug.hbs app/website/views/layouts/default.hbs");
        this.state.end = Date.now();
    }, "server_build_complete");
    
}

