import path from "path";
import optimist from "optimist";

import fsutils   from "../../utils/fs";
import { getLogger } from "../../utils/logging";

import productionBuild from "./builds/production";
import clientDebugBuild from "./builds/client-debug";
import devBuild from "./builds/dev";
import staticBuild from "./builds/static";
import createDatabase from "./builds/create-database";

import { runTasks, getCustomTasks } from "./build-utils/tasks";
import builtInPlugins from "./plugins";

//modes
import defaultConfig from "../../configurations/default";

let configurations = {
    "default": defaultConfig
};

let builds = {
    "production": productionBuild,
    "client-debug": clientDebugBuild,
    "dev": devBuild,
    "static": staticBuild,
    "create-database": createDatabase
};

let argv = optimist.argv;


let printSyntax = (msg) => {
    if (msg) {
        print(`Error: ${msg}`);
    }
    print(`Usage: fora build [<source>] [<destination>]`);
    process.exit();
};


let getParams = function() {
    let args = process.argv.filter(a => !/^-/.test(a));

    if (args.length < 4) {
        printSyntax();
    }
    /* params */
    let source = args[3];
    let destination = args.length >= 5 ? args[4] : "_site";
    return { source, destination };
};

/*
    We have these build modes

    1. Production
        build: "production" or --build production

        We generate server files and client_js files, and skip dev_js files.
        Source-maps are off by default. By default, we compile client_js files
        with full ES5 compatibility.

    2. Client-Debug Build
        build: "client-debug" or --build client-debug

        We generate server files and client_js files, and skip dev_js files.
        Source-maps are on by default. We also compile client_js files
        without regenerator transforms.

    3. Dev Build
        build: "dev" or --build dev

        We do not transpile server js files, since the app will entirely run
        on the client. Source maps are on, and regenerator transforms are off.

    4. Static build
        build: "static" or --build static

        We transpile server js files. We build static html files for each route.
        Client_js files will be transpiled (wil regenerator transforms) and
        source-maps will be on by default.

    5.  Custom named build
        --build "buildname"

        Loads the build from siteConfig.custom_build_dir

*/

let build = function*() {
    let siteConfig = yield* getSiteConfig();

    let logger = getLogger(siteConfig.quiet);

    if (argv.n) {
        siteConfig["build-name"] = argv.n;
    }

    logger(`Source: ${siteConfig.source}`);
    logger(`Destination: ${siteConfig.destination}`);

    /* Start */
    let startTime = Date.now();

    //Transpile custom builds and custom tasks directory first.
    yield* transpileCustomBuildsAndTasks(siteConfig);

    let build = builds[siteConfig["build-name"]] || (yield* getCustomBuild(siteConfig));

    if (build) {
        yield* build(siteConfig);
    } else {
        throw new Error(`Build named ${siteConfig["build-name"]} was not found.`);
    }

    let endTime = Date.now();
    logger(`Total ${(endTime - startTime)/1000} seconds.`);
};


let getSiteConfig = function*() {
    let siteConfig = {};

    let source = args[3] || "./";
    let destination = args.length >= 4 ? args[4] : "_site";

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


/*
    Transpile dir_custom_builds and dir_custom_tasks
*/
let transpileCustomBuildsAndTasks = function*(siteConfig) {
    for(var dir of [siteConfig["custom-builds-dir"], siteConfig["custom-tasks-dir"]]) {
        var buildRoot = path.resolve(siteConfig.source, dir);
        if (yield* fsutils.exists(buildRoot)) {
            yield* runTasks(
                 [{
                     name: "transpile-custom-builds-and-plugins",
                     plugin: builtInPlugins.babel,
                     options: {
                        source: buildRoot,
                        destination: path.resolve(siteConfig.destination, dir),
                        extensions: siteConfig["js-extensions"],
                        blacklist: ["regenerator"]
                    }
                }],
                buildRoot
            );
        }
    }
};


/*
    Get a build from the siteConfig.dir_custom_builds directory.
    Basically, require(dir_custom_builds/buildName);
*/
let getCustomBuild = function*(siteConfig) {
    if (siteConfig["custom-builds-dir"] && siteConfig["build-name"]) {
        let fullPath = path.resolve(siteConfig.destination, siteConfig["custom-builds-dir"], `${siteConfig["build-name"]}.js`);
        if (yield* fsutils.exists(fullPath)) {
            return require(fullPath);
        }
    }
};

export default build;
