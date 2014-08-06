(function () {
    "use strict";

    var path = require('path');
    var fs = require('fs');
    var thunkify = require('fora-node-thunkify');
    var conf = require('../../conf');

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


    var getDirPath = function(dir, subdir) {
        if (dirsAreValid([dir, subdir])) {
            if(['assets', 'images', 'original-images'].indexOf(dir) > -1) {
                if (!isNaN(parseInt(subdir)))
                    return path.join.apply(null, [conf.fileService.publicDirectory].concat([dir, subdir]));
            }
        }
        throw new Error("Invalid directory " + dir + "/" + subdir);
    };


    var getFilePath = function(dir, subdir, file) {
        if (dirsAreValid([dir, subdir]) && filenameIsValid(file)) {
            if (['assets', 'images', 'original-images'].indexOf(dir) > -1) {
                if (!isNaN(parseInt(subdir)))
                    return path.join.apply(null, [conf.fileService.publicDirectory].concat([dir, subdir, file]));
            }
        }
        throw new Error("Invalid directory " + dir + "/" + subdir + "/" + file);
    };


    var getRandomFilePath = function(dir, file) {
        if (dirsAreValid([dir]) && filenameIsValid(file)) {
            var random = (Date.now() % conf.userDirCount).toString();
            if(['assets', 'images', 'original-images'].indexOf(dir) > -1) {
                return path.join.apply(null, [conf.fileService.publicDirectory].concat([dir, random, file]));
            }
        }
        throw new Error("Invalid path " + dir + "/" + file);
    };


    var copyFile = function*(src, dest) {
        src = fs.createReadStream(src);
        dest = fs.createWriteStream(dest);
        src.pipe(dest);
        return yield* thunkify(src.on).call(src, 'end');
    };


    var formatDate = function(date) {
        date = date || new Date();
        var year = date.getFullYear();
        var month = date.getMonth() < 9 ? ("0" + (date.getMonth() + 1)) : (date.getMonth() + 1 + "");
        var dayNum = date.getDate() < 10 ? ("0" + date.getDate()) : (date.getDate() + "");
        return year + "-" + month + "-" + dayNum;
    };

    module.exports = {
        formatDate: formatDate,
        getDirPath: getDirPath,
        getFilePath: getFilePath,
        getRandomFilePath: getRandomFilePath,
        copyFile: copyFile
    };

})();
