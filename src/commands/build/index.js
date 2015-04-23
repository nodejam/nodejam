import path from "path";

import fsutils   from "../../utils/fs";
import { getLogger } from "../../utils/logging";

import productionBuild from "./builds/production";
import clientDebugBuild from "./builds/client-debug";
import devBuild from "./builds/dev";
import staticBuild from "./builds/static";
import createDatabase from "./builds/create-database";

import buildUtils from "./build-utils";
import builtInPlugins from "./plugins";

let builds = {
    "production": productionBuild,
    "client-debug": clientDebugBuild,
    "dev": devBuild,
    "static": staticBuild,
    "create-database": createDatabase
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

let build = function*(siteConfig) {
    let logger = getLogger(siteConfig.quiet);

    logger(`Source: ${siteConfig.source}`);
    logger(`Destination: ${siteConfig.destination}`);

    /* Start */
    let startTime = Date.now();

    //Transpile custom builds and custom tasks directory first.
    yield* transpileCustomBuildsAndTasks(siteConfig);

    let build = builds[siteConfig["build-name"]] || (yield* getCustomBuild(siteConfig));

    if (build) {
        let buildConfig = siteConfig.builds[siteConfig["build-name"]] || {};
        yield* build(siteConfig, buildConfig, builtInPlugins, buildUtils);
    } else {
        throw new Error(`Build named ${siteConfig["build-name"]} was not found.`);
    }

    let endTime = Date.now();
    logger(`Total ${(endTime - startTime)/1000} seconds.`);
};


/*
    Transpile dir_custom_builds and dir_custom_tasks
*/
let transpileCustomBuildsAndTasks = function*(siteConfig) {
    for(var dir of [siteConfig["dir-custom-builds"], siteConfig["dir-custom-tasks"]]) {
        var buildRoot = path.resolve(siteConfig.source, dir);
        if (yield* fsutils.exists(buildRoot)) {
            yield* buildUtils.tasks.runTasks(
                 {
                     name: "transpile-custom-builds-and-plugins",
                     plugin: builtInPlugins.babel,
                     options: {
                        source: buildRoot,
                        destination: path.resolve(siteConfig.destination, dir),
                        extensions: siteConfig["js-extensions"],
                        blacklist: ["regenerator"]
                    }
                },
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
    if (siteConfig["dir-custom-builds"] && siteConfig["build-name"]) {
        let fullPath = path.resolve(siteConfig.destination, siteConfig["dir-custom-builds"], `${siteConfig["build-name"]}.js`);
        if (yield* fsutils.exists(fullPath)) {
            return require(fullPath);
        }
    }
};

export default build;
