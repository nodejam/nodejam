import less from "less";
import path from "path";
import fsutils from "../../../utils/fs";
import promisify from "nodefunc-promisify";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";

const lessc = promisify(less.render.bind(less));
const argv = optimist.argv;

/*
    options: {
        files: [string],
        destination: string,
        directories: [string],
        quiet: bool
    }
*/
const compileLess = function(name, options) {
    const verboseMode = argv[`verbose-${name}`];
    const logger = getLogger(options.quiet, name || "less");

    //defaults
    let directories = options.files
        .map(f => path.dirname(f))
        .filter((item, i, ar) => ar.indexOf(item) === i);

    options.excludedDirectories = options.excludedDirectories || [];

    const extensions = directories.map(dir => `${dir}/*.less`);
    const excluded = options.excludedDirectories.map(dir => `!${dir}/`);

    return function() {
        let mustCompile = false;

        this.watch(
           extensions.concat(excluded),
           async function(filePath, ev, match) {
               mustCompile = true;
           }
        );
        this.onComplete(
            async function() {
                if (mustCompile) {
                    mustCompile = false;
                    for (let filePath of options.files) {
                        const outputPath = path.join(options.destination, filePath).replace(/\.less$/, ".css");
                        logger(`Compiling ${filePath} to ${outputPath}`);

                        const outputDir = path.dirname(outputPath);
                        if (!(await fsutils.exists(outputDir))) {
                            await fsutils.mkdirp(outputDir);
                        }
                        const contents = await fsutils.readFile(filePath);
                        if (contents) {
                            const result = await lessc(contents, { paths: [path.dirname(path.join(options.source, filePath))] });
                            await fsutils.writeFile(outputPath, result.css);
                        }
                    }
                }
            },
            name,
            options.dependencies || []
        );
    };
};

export default compileLess;
