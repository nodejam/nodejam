import less from "less";
import path from "path";
import fsutils from "../../../utils/fs";
import generatorify from "nodefunc-generatorify";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";

let lessc = generatorify(less.render.bind(less));
let argv = optimist.argv;

/*
    options: {
        destination: string,
        directories: [string],
        quiet: bool
    }
*/
let compileLess = function(name, options) {
    let verboseMode = argv[`verbose-${name}`];
    let logger = getLogger(options.quiet, name || "less");

    //defaults
    options.excludedDirectories = options.excludedDirectories || [];

    let extensions = options.directories.map(dir => `${dir}/*.less`);
    let excluded = options.excludedDirectories.map(dir => `!${dir}/`);

    let fn = function() {
        this.watch(
            extensions.concat(excluded),
            function*(filePath, ev, match) {
                let outputPath = path.join(options.destination, filePath).replace(/\.less$/, ".css");
                let outputDir = path.dirname(outputPath);
                if (!(yield* fsutils.exists(outputDir))) {
                    yield* fsutils.mkdirp(outputDir);
                }
                let contents = yield* fsutils.readFile(filePath);
                if (contents) {
                    let result = yield* lessc(contents);
                    yield* fsutils.writeFile(outputPath, result.css);
                }
                logger(`compiled ${filePath} to ${outputPath}`);
            },
            name,
            options.dependencies || []
        );
    };

    return { build: true, fn: fn };
};

export default compileLess;
