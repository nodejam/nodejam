import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";

var build = getStandardBuild("client-debug", function*(siteConfig, buildConfig, builtInPlugins, buildUtils) {
    var { transpileServer, less, copyStaticFiles, writeConfig, writeClientConfig } = getCommonTasks(siteConfig, buildConfig, builtInPlugins);
    var tasks = [transpileServer, less, copyStaticFiles, writeConfig, writeClientConfig];

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
            excludedDirectories: siteConfig["dirs-client-vendor"].concat(siteConfig["dirs-exclude"]),
            excludedPatterns: siteConfig["patterns-exclude"],
            buildSpecificJSSuffix: siteConfig["client-js-suffix"],
            originalJSSuffix: siteConfig["original-js-suffix"],
            excludedWatchPatterns: siteConfig["dev-js-suffix"] ? [new RegExp(`${siteConfig["dev-js-suffix"]}\.(js|json)$`)] : [],
            blacklist: configutils.tryRead(buildConfig, ["tasks", "build-client", "es6-transpile", "blacklist"], [])
        }
    });

    return tasks;
});

export default build;
