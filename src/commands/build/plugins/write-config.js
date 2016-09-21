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
      async function() {
        const outputPath = path.join(options.destination, options.filename);
        logger(`Writing config to ${outputPath}`);
        await fsutils.ensureDirExists(outputPath);
        await fsutils.writeFile(outputPath, JSON.stringify(options.config, null, "\t"));
      },
      name
    );
  };
};

export default writeConfig;
