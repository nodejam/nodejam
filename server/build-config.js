co = require('co');
thunkify = require('thunkify');
fs = require('fs');

spawn = require('child_process').spawn;
_exec = require('child_process').exec
exec = thunkify(function(cmd, cb) {
    _exec(cmd, function(err, stdout, stderr) {
        log(cmd);
        cb(err, stdout.substring(0, stdout.length - 1));
    });
});

react = require('react-tools');

module.exports = function(config) {
    /*
        App restart task
    */
    appRestart = function*() {
        if (!this.state.queuedRestart) {
            this.queue(function*() {
                script = spawn("sh", ["run.sh"]);
                script.stdout.on("data", log)
                script.stderr.on("data", log)
            });
            this.state.queuedRestart = true;
        }
    }
    
    /*
        Compile all coffee-script files
        Coffee doesn't do coffee {src} {dest} yet, hence the redirection.
    */
    config.files(["src/*.coffee -r"], function*(filePath) {
            dest = filePath.replace(/^src\//, 'app').replace(/\.coffee$/, '.js');
            yield exec("coffee -cs <" + filePath + " >" + dest);
            yield appRestart.call(this);
        }
    );

        
    /*
        Compile all JSX files
        Copy the final scripts to the www-client directory for browsers
    */
    config.files(["src/app-lib/fora-ui/*.jsx -r", "src/extensions/*.jsx -r", "src/website/views/*.jsx -r"], function*(filePath) {
            dest = filePath.replace(/^src\//, 'app').replace(/\.jsx$/, '.js');
            contents = fs.readFileSync(filePath);
            result = react.transform(contents.toString());
            fs.writeFileSync(dest, result);
            yield exec("cp " + dest + " " + dest.replace(/^app\//, "../www-client/app/www/shared/"));
            yield appRestart.call(this);
        }
    );


    /*
        Compile all hbs files
        Remove -debug if it exists
    */
    config.files(["src/website/views/*.hbs -r"], function*(filePath) {
            dest = filePath.replace(/^src\//, 'app').replace(/-debug\.hbs$/, 'hbs');
            yield exec("cp " + src + " " + dest);
            yield appRestart.call(this);
        }
    );
}

