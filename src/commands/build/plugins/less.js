import less from "less";
import path from "path";
import fsutils from "../../../utils/fs";
import generatorify from "nodefunc-generatorify";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";

const lessc = generatorify(less.render.bind(less));
const argv = optimist.argv;

/*
    options: {
        destination: string,
        directories: [string],
        quiet: bool
    }
*/
const compileLess = function(name, options) {
    const verboseMode = argv[`verbose-${name}`];
    const logger = getLogger(options.quiet, name || "less");

    //defaults
    options.excludedDirectories = options.excludedDirectories || [];

    const extensions = options.directories.map(dir => `${dir}/*.less`);
    const excluded = options.excludedDirectories.map(dir => `!${dir}/`);

    return function() {
        this.watch(
            extensions.concat(excluded),
            function*(filePath, ev, match) {
                const outputPath = path.join(options.destination, filePath).replace(/\.less$/, ".css");
                const outputDir = path.dirname(outputPath);
                if (!(yield* fsutils.exists(outputDir))) {
                    yield* fsutils.mkdirp(outputDir);
                }
                const contents = yield* fsutils.readFile(filePath);
                if (contents) {
                    const result = yield* lessc(contents);
                    yield* fsutils.writeFile(outputPath, result.css);
                }
                logger(`compiled ${filePath} to ${outputPath}`);
            },
            name,
            options.dependencies || []
        );
    };
};

export default compileLess;
