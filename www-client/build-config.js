(function () {
    "option strict"

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

    module.exports = function(config) {

        ensureDirExists = function*(file) {
            var dir = path.dirname(file);
            if (!fs.existsSync(dir)) {
                yield exec("mkdir " + dir + " -p");
            } 
        }
        
        /*
            When the build starts, recreate the app directory
        */
        config.onStart(function*() {
            console.log("Started fora/www-client build");
            yield exec("rm app -rf");
            yield exec("mkdir app");        
        });
        

        /*
            Compile all coffee-script files
            Coffee doesn't do coffee {src} {dest} yet, hence the redirection.
        */
        config.files(["src/*.coffee"], function*(filePath) {
            var dest = filePath.replace(/^src\//, 'app/').replace(/\.coffee$/, '.js');
            yield ensureDirExists(dest);
            yield exec("coffee -cs < " + filePath + " > " + dest);
        });

            
        /*
            Compile all JSX files from the server directory.
        */
        config.files(["../server/app/app-lib/fora-ui/*.js", "../server/app/extensions/*.js", "../server/app/website/views/*.js"], function*(filePath) {
            var clientDest = filePath.replace(/^\.\.\/server\/app\//, "app/www/shared/");            
            yield ensureDirExists(clientDest);
            yield exec("cp " + filePath + " " + clientDest);
        });
        
        
        /*
            Copy other files, except .coffee and .less
        */
        config.files(["src/www/*.*"], function*(filePath) {
            if (['.coffee', '.less'].indexOf(path.extname(filePath)) === -1) {
                var dest = filePath.replace(/^src\//, 'app/');
                yield ensureDirExists(dest);
                yield exec("cp " + filePath + " " + dest);
                yield appRestart.call(this);
            }
        });
        
        /*
            Compile less files
        */
        config.files(["src/www/css/*.less"], function*(filePath) {
            if (!this.state.lessCompilationPending) {
                this.state.lessCompilationPending = true;
                this.onComplete(function*() {
                    yield exec("lessc --verbose src/www/css/main.less app/www/css/main.css");
                });
            }
        });
        
        
        /*
            Do regeneator transform on all client side js files
        */
        config.files(["app/www/js/*.js", "app/www/shared/*.js"], function*(filePath) {
            yield exec("regenerator " + filePath + " > " + filePath);
        });
    }
}());

