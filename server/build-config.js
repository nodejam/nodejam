"option strict"

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

module.exports = function(config) {
    /*
        App restart job. 
        When files on the server change, a restart is necessary.
    */
    config.job(function*() {
        console.log("hello.....");
        //var script = spawn("sh", ["run.sh"]);
    }, "restart_server");

    
    /*
        Make sure directory exists for path
    */
    ensureDirExists = function*(file) {
        var dir = path.dirname(file);
        if (!fs.existsSync(dir)) {
            yield exec("mkdir " + dir + " -p");
        } 
    }
    

    /*
        When the build starts, recreate the app directory
    */
    config.onBuildStart(function*() {
        console.log("Started fora/server build");
        this.state.start = Date.now(); //Note the time
        yield exec("rm app -rf");
        yield exec("mkdir app");        
    }, "server_build_start");
    

    /*
        Compile all coffee-script files
        Coffee doesn't do coffee {src} {dest} yet, hence the redirection.
    */
    config.watch(["src/*.coffee"], function*(filePath) {
        var dest = filePath.replace(/^src\//, 'app/').replace(/\.coffee$/, '.js');
        yield ensureDirExists(dest);
        yield exec("coffee -cs < " + filePath + " > " + dest);
        this.queue('restart_server');
    }, "server_coffee_compile");

        
    /*
        Compile all JSX files
        Use the React Tools API for this; there is no way to do this from the command line
    */
    config.watch(["src/app-lib/fora-ui/*.jsx", "src/extensions/*.jsx", "src/website/views/*.jsx"], function*(filePath) {
        var dest = filePath.replace(/^src\//, 'app/').replace(/\.jsx$/, '.js');
        var clientDest = dest.replace(/^app\//, "../www-client/app/www/shared/");
        yield ensureDirExists(dest);
        yield ensureDirExists(clientDest);

        var contents = fs.readFileSync(filePath);
        var result = react.transform(contents.toString());
        fs.writeFileSync(dest, result);
        yield exec("cp " + dest + " " + clientDest);
        this.queue('restart_server');
    }, "server_jsx_compile");
    

    /*
        Copy other files
    */
    config.watch(["src/vendor/*.*", "src/conf/*.config", "src/extensions/*.json", "src/extensions/*.js"], function*(filePath) {
        var dest = filePath.replace(/^src\//, 'app/');
        yield ensureDirExists(dest);
        yield exec("cp " + filePath + " " + dest);
        this.queue('restart_server');
    }, "server_files_copy");
       

    /*
        Copy all hbs files, except layouts/default.hbs and layouts/default-debug.hbs
    */
    config.watch(["src/website/views/*.hbs"], function*(filePath) {
        if (!(/layouts\/default.hbs$/).test(filePath) && !(/layouts\/default-debug.hbs$/).test(filePath)) {
            var dest = filePath.replace(/^src\//, 'app/');
            yield ensureDirExists(dest);
            yield exec("cp " + filePath + " " + dest);
            this.queue('restart_server');
        }
    }, "server_hbs_copy");
    

    /*
        Copy layouts/default.hbs OR layouts/default-debug.hbs
    */
    var layoutFile = argv.debug ? "src/website/views/layouts/default-debug.hbs" : "src/website/views/layouts/default.hbs";
    config.watch([layoutFile], function*(filePath) {
        var dest = "app/website/views/layouts/default.hbs";
        yield ensureDirExists(dest);
        yield exec("cp " + filePath + " " + dest);
        this.queue('restart_server');
    }, "server_hbs_layout_copy");
    

    /*
        Just to note when it finished
    */
    config.onBuildComplete(function*() {
        this.state.end = Date.now();
    }, "server_build_complete");
    
}

