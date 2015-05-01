import {transform} from "babel";
import optimist from "optimist";
import path from "path";
import fsutils from "../../../utils/fs";
import { print, getLogger } from "../../../utils/logging";

let argv = optimist.argv;

/*
    options: {
        destination: string,
        extensions: [string],
        excludedFiles: [string],
        excludedDirectories: [string],
        excludedPatterns: [regex or string],
        excludedWatchPatterns: [regex],
        blacklist: [string],
        quiet: bool
    }
*/

let babel = function(name, options) {
    let verboseMode = argv[`verbose-${name}`];
    let logger = getLogger(options.quiet, name || "babel");

    //defaults
    options.extensions = options.extensions || ["js", "jsx"];
    options.excludedFiles = options.excludedFiles || [];
    options.excludedDirectories = (options.excludedDirectories || []).concat(options.destination);
    options.excludedPatterns = options.excludedPatterns || [];
    options.blacklist = options.blacklist || [];
    options.excludedWatchPatterns = (options.excludedWatchPatterns || []).map(p => new RegExp(p));

    let fn = function() {
        let extensions = options.extensions.map(e => `*.${e}`);

        let excluded = options.excludedDirectories.map(dir => `!${dir}/`)
            .concat(options.excludedFiles.map(e => `!${e}`))
            .concat(options.excludedPatterns.map(e => { return { exclude: e.exclude, regex: new RegExp(e.regex) }; }));

        let transpiledFiles = [];

        this.watch(
            extensions.concat(excluded),
            function*(filePath, ev, match) {
                if (!options.excludedWatchPatterns.some(regex => regex.test(filePath))) {
                    transpiledFiles.push(filePath);

                    //Make the output dir, if it doesn't exist
                    let outputPath = fsutils.changeExtension(
                        path.join(options.destination, filePath),
                        [ { to:"js", from: options.extensions }]
                    );
                    yield* fsutils.ensureDirExists(outputPath);
                    let contents = yield* fsutils.readFile(filePath);

                    let result = transform(contents, { blacklist: options.blacklist });
                    yield* fsutils.writeFile(outputPath, result.code);

                    if (verboseMode) {
                        logger(`${filePath} -> ${outputPath}`);
                    }
                }
            },
            name, 
            options.dependencies || []
        );

        this.onComplete(function*() {
            logger(`rewrote ${transpiledFiles.length} files`);
        });
    };

    return { build: true, fn: fn };
};

export default babel;
