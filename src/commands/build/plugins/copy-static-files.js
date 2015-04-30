import path from "path";
import fs from "fs";
import fsutils from "../../../utils/fs";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";

let argv = optimist.argv;
/*
    options: {
        destination: string,
        extensions: [string],
        excludedFiles: [string],
        excludedDirectories: [string],
        excludedPatterns: [regex or string],
        excludedExtensions: [string],
        excludedWatchPatterns = [regex],
        changeExtensions: [ { to: "js", from: ["es6", "jsx"]}]
        quiet: bool
    }
*/
let copyStaticFiles = function(name, options) {
    let verboseMode = argv[`verbose-${name}`];
    let logger = getLogger(options.quiet, name || "copy-static-files");

    //defaults
    options.extensions = options.extensions || ["*.*"];
    options.excludedFiles = options.excludedFiles || [];
    options.excludedDirectories = (options.excludedDirectories || []).concat(options.destination);
    options.excludedPatterns = options.excludedPatterns || [];
    options.excludedExtensions = options.excludedExtensions || [];
    options.excludedWatchPatterns = options.excludedWatchPatterns || [];

    var excludedWatchPatterns = options.excludedWatchPatterns.map(r => new RegExp(r));

    let fn = function() {
        let excluded = options.excludedDirectories.map(dir => `!${dir}/`)
            .concat(options.excludedFiles.map(e => `!${e}`))
            .concat(options.excludedExtensions.map(ext => `!*.${ext}`))
            .concat(options.excludedPatterns.map(e => { return { exclude: e.exclude, regex: new RegExp(e.regex) }; }));

        let copiedFiles = [];

        this.watch(options.extensions.concat(excluded), function*(filePath, ev, matches) {
            if (!excludedWatchPatterns.some(regex => regex.test(filePath))) {
                copiedFiles.push(filePath);
                let newFilePath = fsutils.changeExtension(filePath, options.changeExtensions);
                let outputPath = path.join(options.destination, newFilePath);
                yield* fsutils.copyFile(filePath, outputPath, { overwrite: false });

                if (verboseMode) {
                    logger(`${filePath} -> ${outputPath}`);
                }
            }
        }, "copy-static-files");

        this.onComplete(function*() {
            logger(`copied ${copiedFiles.length} files`);
        });
    };

    return { build: true, fn: fn };
};

export default copyStaticFiles;
