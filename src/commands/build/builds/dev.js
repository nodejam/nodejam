import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";

var build = getStandardBuild("dev", function*(siteConfig, buildConfig, builtInPlugins, buildUtils) {
    var { less, copyStaticFiles, writeConfig, writeClientConfig } = getCommonTasks(siteConfig, buildConfig, builtInPlugins);

    //In the dev build we wouldn't need server-side JS files.
    //They will anyway be copied into the client directory by the build-client plugin.
    copyStaticFiles.options.extensions = ["*.*", "vendor/*.js"];
    copyStaticFiles.options.excludedExtensions = (copyStaticFiles.options.excludedExtensions || []).concat(["js", "jsx", "json"]);

    var tasks = [less, copyStaticFiles, writeConfig, writeClientConfig];

    tasks.push({
        name: "build-client", //build client js bundle
        plugin: builtInPlugins["build-client"],
        options: {
            source: siteConfig.source,
            destination: siteConfig.destination,
            clientBuildDirectory: siteConfig["dir-client-build"],
            appEntryPoint: siteConfig["app-entry-point"],
            bundleName: siteConfig["client-bundle-name"],
            extensions: ["js", "jsx", "json"],
            changeExtensions: configutils.tryRead(buildConfig, ["tasks", "build-client", "change-extensions"], [{ to: "js", from: ["jsx"] }]),
            debug: true,
            globalModules: configutils.tryRead(buildConfig, ["tasks", "build-client", "global-modules"], []),
            excludedModules: configutils.tryRead(buildConfig, ["tasks", "build-client", "excluded-modules"], []),
            excludedDirectories: [siteConfig.destination]
                .concat(configutils.tryRead(buildConfig, ["tasks", "build-client", "patterns-exclude"], []))
                .concat(siteConfig["dirs-client-vendor"])
                .concat(siteConfig["dirs-exclude"]),
            excludedPatterns: siteConfig["patterns-exclude"],
            buildSpecificJSSuffix: siteConfig["dev-js-suffix"],
            originalJSSuffix: siteConfig["original-js-suffix"],
            excludedWatchPatterns: siteConfig["client-js-suffix"] ? [new RegExp(`${siteConfig["client-js-suffix"]}\.(js|json)$`)] : [],
            blacklist: configutils.tryRead(buildConfig, ["tasks", "build-client", "es6-transpile", "blacklist"], [])
        }
    });

    return tasks;
});

export default build;
