co = require('co');
thunkify = require('thunkify');
fs = require('fs');
path = require('path');
argv = require('optimist').argv;

spawn = require('child_process').spawn;
_exec = require('child_process').exec
exec = thunkify(function(cmd, cb) {
    console.log(cmd);
    _exec(cmd, function(err, stdout, stderr) {
        cb(err, stdout.substring(0, stdout.length - 1));
    });
});

react = require('react-tools');

module.exports = function() {
    
    //So that we can minify everything in production
    var jsFiles = [];
    

    ensureDirExists = function*(file) {
        var dir = path.dirname(file);
        if (!fs.existsSync(dir)) {
            yield exec("mkdir " + dir + " -p");
        } 
    }
    
    /*
        When the build starts, recreate the app directory
    */
    this.onBuildStart(function*() {
        console.log("Started fora/www-client build");
        this.state.start = Date.now();
        yield exec("rm app -rf");
        yield exec("mkdir app");        
    }, "client_build_start");
    

    /*
        Compile all coffee-script files
        Coffee doesn't do coffee {src} {dest} yet, hence the redirection.
    */
    this.watch(["src/*.coffee"], function*(filePath) {
        var dest = filePath.replace(/^src\//, 'app/').replace(/\.coffee$/, '.js');
        yield ensureDirExists(dest);
        yield exec("coffee -cs < " + filePath + " > " + dest);
        jsFiles.push(dest);
    }, "client_coffee_compile");

        
    /*
        Compile all JSX files from the server directory.
    */
    this.watch(["../server/app/app-lib/fora-ui/*.js", "../server/app/extensions/*.js", "../server/app/website/views/*.js"], function*(filePath) {
        var dest = filePath.replace(/^\.\.\/server\/app\//, "app/www/shared/");            
        yield ensureDirExists(dest);
        yield exec("cp " + filePath + " " + dest);
        jsFiles.push(dest);
    }, "client_jsx_copy");
    
    
    /*
        Copy other files, except .coffee and .less
    */
    this.watch(["src/www/*.*"], function*(filePath) {
        if (/(\.coffee$)|(\.less$)/.test(path.extname(filePath)) === -1) {
            var dest = filePath.replace(/^src\//, 'app/');
            yield ensureDirExists(dest);
            yield exec("cp " + filePath + " " + dest);
        }
    }, "client_files_copy");
    

    /*
        Do facebook regenerator transform on all client side js files
    */
    this.watch(["app/www/js/*.js", "app/www/shared/*.js"], function*(filePath) {
        result = yield exec("regenerator " + filePath);
        fs.writeFileSync(filePath, result);
    }, "client_regenerator_transform", ["client_coffee_compile", "client_jsx_copy"]);


    /*
        Compile less files. Schedule it at the end.
    */
    this.watch(["src/www/css/*.less"], function*(filePath) {
        if (!this.state.lesscQueued) {
            this.state.lesscQueued = true;
            this.queue(function*() {
                yield exec("lessc --verbose src/www/css/main.less app/www/css/main.css");
            });
        }
    }, "client_less_compile");
    
    
    /*
        If debug, include all unminified js files. Otherwise minify.
        Finally, go back and change debug.hbs
    */
    this.onBuildComplete(function*() {
        var jsInclude = "";
        if (argv.debug) {
            jsFiles.forEach(function(file) {
                jsInclude += "<script src=\"" + file.replace(/^app\/www/, '') + "\" type=\"text/javascript\"></script>\r\n"            
            });
        } else {
            //TODO: minify
            jsInclude = "<script src=\"/js/fora.js\" type=\"text/javascript\"></script>"           
        }
        this.state.end = Date.now();
    }, "client_build_complete");
}
