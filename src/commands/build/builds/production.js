import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";

let build = getStandardBuild("production", function*(siteConfig, buildConfig, builtInPlugins, buildUtils) {
    let { transpileServer, less, copyStaticFiles, writeConfig, writeClientConfig } = getCommonTasks(siteConfig, buildConfig, builtInPlugins);
    let tasks = [transpileServer, less, copyStaticFiles, writeConfig, writeClientConfig];

    let getBuildClientTask = function() {
        let buildClientReader = configutils.getReader(siteConfig, ["tasks", "build-browser-app"]);

        let vendorDirs = buildClientReader(["vendor-dirs"], ["vendor"]);
        let changeExtensions = buildClientReader(["change-extensions"], [{ to: "js", from: ["jsx"] }]);
        let clientBuildDirectory = buildClientReader(["dir-build"], "js");
        let appEntryPoint = buildClientReader(["entry-point"], "app.js");
        let bundleName = buildClientReader(["bundle-name"], "app.bundle.js");
        let extensions = buildClientReader(["extensions"], ["js", "jsx", "json"]);
        let globalModules = buildClientReader(["global-modules"], []);
        let excludedModules = buildClientReader(["excluded-modules"], []);
        let excludedDirectories = buildClientReader(["excluded-dirs"], []);
        let excludedPatterns = buildClientReader(["excluded-patterns"], []);
        let specializationFileSuffix = buildClientReader(["specialization-file-suffix"], "~client");
        let replacedFileSuffix = buildClientReader(["replaced-file-suffix"], "_base");
        let excludedWatchPatterns = buildClientReader(["excluded-watch-patterns"], []);
        let blacklist = buildClientReader(["blacklist"], []);

        return {
            name: "build-browser-app", //build client js bundle
            plugin: builtInPlugins["build-browser-app"],
            options: {
                source: siteConfig.source,
                destination: siteConfig.destination,
                clientBuildDirectory,
                appEntryPoint,
                bundleName,
                extensions,
                changeExtensions,
                debug: false,
                globalModules,
                excludedModules,
                excludedDirectories: vendorDirs.concat(excludedDirectories),
                excludedPatterns,
                specializationFileSuffix,
                replacedFileSuffix,
                excludedWatchPatterns: excludedWatchPatterns ? [new RegExp(`${excludedWatchPatterns}\.(js|json)$`)] : [],
                blacklist,
            }
        };
    };

    tasks.push(getBuildClientTask());

    return tasks;
});

export default build;
