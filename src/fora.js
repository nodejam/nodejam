//This polyfill is needed on ES5
require("babel/polyfill");

import co from "co";
import optimist from "optimist";
import * as commands from "./commands";
import yaml from "js-yaml";
import path from "path";
import configutils from "./utils/config";
import fsutils from "./utils/fs";
import { print } from "./utils/logging";
import readFileByFormat from "./utils/file-reader";

//modes
import defaultConfig from "./configurations/default";
import jekyllConfig from "./configurations/jekyll";

let configurations = {
    "default": defaultConfig,
    "jekyll": jekyllConfig
};


let argv = optimist.argv;

//debug mode?
if (argv.debug) {
    GLOBAL.CO_PARALLEL_TOOLS_DEBUG = true;
}

//Commands might need the templates directory. Easier from root.
GLOBAL.__libdir = __dirname;


let getSiteConfig = function*() {
    let siteConfig = {};

    let source = argv.source || argv.s || "./";
    let destination = argv.destination || argv.d || "_site";

    let configFilePath = argv.config ? path.join(source, argv.config) :
        (yield* fsutils.exists(path.join(source, "config.json"))) ? path.join(source, "config.json") : path.join(source, "config.yml");

    siteConfig = yield* readFileByFormat(configFilePath);
    siteConfig.mode = siteConfig.mode || "default";

    let modeSpecificConfigDefaults = configurations[siteConfig.mode].loadDefaults(source, destination);
    let defaults = configutils.getFullyQualifiedProperties(modeSpecificConfigDefaults);

    let setter = configutils.getValueSetter(siteConfig);
    for (let args of defaults) {
        setter.apply(null, args);
    }

    configutils.commandLineSetter(siteConfig);

    //Store absolute paths for source and destination
    siteConfig.source = path.resolve(siteConfig.source);
    siteConfig.destination = path.resolve(siteConfig.source, siteConfig.destination);

    //Give modes one chance to update the siteConfig
    if (configurations[siteConfig.mode].updateSiteConfig)
    configurations[siteConfig.mode].updateSiteConfig(siteConfig);

    return siteConfig;
};


let getCommand = function() {
    return (
        (argv.help || argv.h) ? "help" :
        (argv.version || argv.v) ? "version" :
        process.argv[2]
    );
};


co(function*() {
    try {
        let commandName = getCommand();
        if (commandName) {
            let command = commands[`_${commandName}`];
            if (["new", "help", "version"].indexOf(commandName) !== -1) {
                yield* command();
            } else {
                let config = yield* getSiteConfig();
                yield* command(config);
            }
        } else {
            print("Invalid command. Use --help for more information.");
        }
    }
    catch(err) {
        print(err.stack);
    }
});
