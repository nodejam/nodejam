var crankshaft = require("crankshaft");
var path = require("path");
var fs = require("fs");
var fsutils = require("./src/utils/fs");
var babel = require("babel");
var build = crankshaft.create();

/*
    Remove the lib directory if it exists.
*/
build.onStart(function*() {
    if (yield* fsutils.exists("lib"))
        yield* fsutils.remove("lib");
});

build.configure(function() {
    var excluded = [ "!node_modules/", "!.git/"];

    /*
        Transpile js and jsx with babel.
    */
    this.watch(["src/*.js"].concat(excluded), function*(filePath, ev, match) {
        var outputPath = filePath.replace(/^src\//, "lib/");
        var outputDir = path.dirname(outputPath);
        if (!(yield* fsutils.exists(outputDir))) {
            yield* fsutils.mkdirp(outputDir);
        }
        var contents = yield* fsutils.readFile(filePath);
        var result = babel.transform(contents, { blacklist: ["regenerator", "es6.constants", "es6.blockScoping"] });
        yield* fsutils.writeFile(outputPath, result.code);
    }, "babel");

    this.watch(["src/*.*", "!src/*.js"].concat(excluded), function*(filePath, ev, match) {
        var outputPath = filePath.replace(/^src\//, "lib/");
        var outputDir = path.dirname(outputPath);
        if (!(yield* fsutils.exists(outputDir))) {
            yield* fsutils.mkdirp(outputDir);
        }
        fs.createReadStream(filePath).pipe(fs.createWriteStream(outputPath));
    }, "copy_all");

}, ".");

crankshaft.run(build)
    .catch(function(err) {
        console.log(err);
        console.log(err.stack);
    });
