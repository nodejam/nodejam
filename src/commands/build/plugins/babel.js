import {transform} from "babel";
import optimist from "optimist";
import path from "path";
import fsutils from "../../../utils/fs";
import { print, getLogger } from "../../../utils/logging";

const argv = optimist.argv;

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

const babel = function(name, options) {
    const verboseMode = argv[`verbose-${name}`];
    const logger = getLogger(options.quiet, name || "babel");

    //defaults
    options.extensions = options.extensions || ["js", "jsx"];
    options.excludedFiles = options.excludedFiles || [];
    options.excludedDirectories = (options.excludedDirectories || []).concat(options.destination);
    options.excludedPatterns = options.excludedPatterns || [];
    options.blacklist = options.blacklist || [];
    options.excludedWatchPatterns = (options.excludedWatchPatterns || []).map(p => new RegExp(p));

    return function() {
        const extensions = options.extensions.map(e => `*.${e}`);

        const excluded = options.excludedDirectories.map(dir => `!${dir}/`)
            .concat(options.excludedFiles.map(e => `!${e}`))
            .concat(options.excludedPatterns.map(e => { return { exclude: e.exclude, regex: new RegExp(e.regex) }; }));

        const transpiledFiles = [];

        this.watch(
            extensions.concat(excluded),
            function*(filePath, ev, match) {
                if (!options.excludedWatchPatterns.some(regex => regex.test(filePath))) {
                    transpiledFiles.push(filePath);

                    //Make the output dir, if it doesn't exist
                    const outputPath = fsutils.changeExtension(
                        path.join(options.destination, filePath),
                        [ { to:"js", from: options.extensions }]
                    );
                    yield* fsutils.ensureDirExists(outputPath);
                    const contents = yield* fsutils.readFile(filePath);

                    const result = transform(contents, { blacklist: options.blacklist });
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
            logger(`Rewrote ${transpiledFiles.length} files`);
        });
    };
};

export default babel;
