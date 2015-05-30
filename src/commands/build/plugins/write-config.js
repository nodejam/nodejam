import path from "path";
import fsutils from "../../../utils/fs";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";

const argv = optimist.argv;

/*
    options: {
        filename: filename,
        destination: string,
        config: config,
        quiet: bool
    }
*/
const writeConfig = function(name, options) {
    const verboseMode = argv[`verbose-${name}`];
    const logger = getLogger(options.quiet, name || "write-config");

    //defaults
    options.filename = options.filename || "config.json";

    return function() {
        this.onStart(
            function*() {
                const outputPath = path.join(options.destination, options.filename);
                yield* fsutils.ensureDirExists(outputPath);
                yield* fsutils.writeFile(outputPath, JSON.stringify(options.config, null, "\t"));
                logger(`Wrote config to ${outputPath}`);
            },
            name
        );
    };
};

export default writeConfig;
