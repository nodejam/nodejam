import path from "path";
import fsutils from "../../../utils/fs";
import { print, getLogger } from "../../../utils/logging";


/*
    options: {
        filename: filename,
        destination: string,
        config: config,
        quiet: bool
    }
*/
let writeConfig = function(name, options) {
    let logger = getLogger(options.quiet, name || "write-config");

    //defaults
    options.filename = options.filename || "config.json";

    let fn = function*() {
        let outputPath = path.join(options.destination, options.filename);
        yield* fsutils.ensureDirExists(outputPath);
        yield* fsutils.writeFile(outputPath, JSON.stringify(options.config, null, "\t"));
        logger(`Wrote config to ${outputPath}`);
    };
    return { build: false, fn: fn };
};

export default writeConfig;
