/*
IMPORTANT! No ES6 allowed.
This file is used by the build bootstrap.
*/

import fs from "fs";
import promisify from "nodefunc-promisify";
import extfs from 'extfs';
import _mkdirp from "mkdirp";
import wrench from "wrench";
import rimraf from "rimraf";
import path from "path";

const mkdirp = promisify(_mkdirp);

const exists = promisify(function(what, cb) {
  fs.exists(what, function(exists) {
    cb(null, exists);
  });
});

const ensureDirExists = async function(outputPath) {
  const outputDir = path.dirname(outputPath);
  if (!(await exists(outputDir))) {
    await mkdirp(outputDir);
  }
};


const empty = promisify(function(path, cb) {
  extfs.isEmpty(path, function(result) {
    cb(null, result);
  });
});

const readFile = async function() {
  const fn = promisify(fs.readFile);
  return (await fn.apply(null, arguments)).toString();
};

const _doCopy = promisify(function(source, target, cb) {
  let cbCalled = false;

  const rd = fs.createReadStream(source);
  rd.on("error", function(err) {
    done(err);
  });
  const wr = fs.createWriteStream(target);
  wr.on("error", function(err) {
    done(err);
  });
  wr.on("close", function(ex) {
    done();
  });
  rd.pipe(wr);

  function done(err) {
    if (!cbCalled) {
      cb(err);
      cbCalled = true;
    }
  }
});

const copyFile = async function(source, target, options) {
  options = options || {};
  if (typeof options.overwrite === "undefined" || options.overwrite === null)
  options.overwrite = true;
  if (typeof options.createDir === "undefined" || options.createDir === null)
  options.createDir = true;

  const outputDir = path.dirname(target);

  if (options.createDir && !(await exists(outputDir))) {
    await mkdirp(outputDir);
  }

  if (!options.overwrite && (await exists(target))) {
    return;
  }

  return await _doCopy(source, target);
};

/*
Changes the extension to toExtension
If fromExtensions[array] is not empty, filePath is changed only if extension is in fromExtensions
*/
const changeExtension = function(filePath, extensions) {
  const dir = path.dirname(filePath);
  const fileExtension = path.extname(filePath);
  const filename = path.basename(filePath, fileExtension);
  for (let i = 0; i < extensions.length; i++) {
    const extension = extensions[i];
    if (extension.from && extension.from.length) {
      if (extension.from.indexOf(fileExtension.split(".")[1]) !== -1)
      return path.join(dir, `${filename}.${extension.to}`);
    } else {
      return path.join(dir, `${filename}.${extension.to}`);
    }
  }
  return filePath;
};

module.exports = {
  readFile: readFile,
  writeFile: promisify(fs.writeFile),
  copyFile: copyFile,
  mkdirp: mkdirp,
  ensureDirExists: ensureDirExists,
  copyRecursive: promisify(wrench.copyDirRecursive),
  exists: exists,
  empty: empty,
  changeExtension: changeExtension,
  remove: promisify(rimraf),
  readdir: promisify(fs.readdir)
};
