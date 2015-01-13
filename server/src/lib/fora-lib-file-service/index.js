(function () {
    "use strict";

    var path = require('path'),
        fs = require('fs'),
        promisify = require('nodefunc-promisify');


    var FileService = function(configuration) {
        this.configuration = configuration;
    };


    var formatDate = function(date) {
        date = date || new Date();
        var year = date.getFullYear();
        var month = date.getMonth() < 9 ? ("0" + (date.getMonth() + 1)) : (date.getMonth() + 1 + "");
        var dayNum = date.getDate() < 10 ? ("0" + date.getDate()) : (date.getDate() + "");
        return year + "-" + month + "-" + dayNum;
    };


    var dirsAreValid = function(dirs) {
        var regex = /[a-zA-z0-9][a-zA-z0-9_\-]*/;
        if (dirs instanceof Array) {
            for (var i = 0; i < dirs.length; i++) {
                if (!regex.test(dirs[i])) return false;
            }
            return true;
        } else {
            throw new Error("Parameter must be an array");
        }
    };


    var filenameIsValid = function(file) {
        //At the moment we allow only abcdef.xyz
        return /[a-zA-z0-9][a-zA-z0-9_\-]*\.[a-zA-z]{3}/.test(file);
    };


    FileService.prototype.getDirPath = function(dir, subdir) {
        if (dirsAreValid([dir, subdir])) {
            if(['assets', 'images', 'original-images'].indexOf(dir) > -1) {
                if (!isNaN(parseInt(subdir)))
                    return path.join.apply(null, [this.configuration.services.file.publicDirectory].concat([dir, subdir]));
            }
        }
        throw new Error("Invalid directory " + dir + "/" + subdir);
    };


    FileService.prototype.getFilePath = function(dir, subdir, file) {
        if (dirsAreValid([dir, subdir]) && filenameIsValid(file)) {
            if (['assets', 'images', 'original-images'].indexOf(dir) > -1) {
                if (!isNaN(parseInt(subdir)))
                    return path.join.apply(null, [this.configuration.services.file.publicDirectory].concat([dir, subdir, file]));
            }
        }
        throw new Error("Invalid directory " + dir + "/" + subdir + "/" + file);
    };


    FileService.prototype.getRandomFilePath = function(dir, file) {
        if (dirsAreValid([dir]) && filenameIsValid(file)) {
            var random = (Date.now() % this.configuration.services.file.userDirCount).toString();
            if(['assets', 'images', 'original-images'].indexOf(dir) > -1) {
                return path.join.apply(null, [this.configuration.services.file.publicDirectory].concat([dir, random, file]));
            }
        }
        throw new Error("Invalid path " + dir + "/" + file);
    };


    FileService.prototype.copyFile = function*(src, dest) {
        src = fs.createReadStream(src);
        dest = fs.createWriteStream(dest);
        src.pipe(dest);
        return yield promisify.call(src, src.on)('end');
    };


    module.exports = FileService;

})();
