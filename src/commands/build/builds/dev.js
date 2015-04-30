import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";

let data = {};

let build = getStandardBuild(
    "dev",
    function*(siteConfig, buildConfig, builtInPlugins, buildUtils) {
        let { less, copyStaticFiles, writeConfig, writeClientConfig } = getCommonTasks(siteConfig, buildConfig, builtInPlugins);

        //In the dev build we wouldn't need server-side JS files.
        //They will anyway be copied into the client directory by the build-browser-app plugin.
        copyStaticFiles.options.extensions = ["*.*", "vendor/*.js"];
        copyStaticFiles.options.excludedExtensions = (copyStaticFiles.options.excludedExtensions || []).concat(["js", "jsx", "json"]);

        let tasks = [less, copyStaticFiles, writeConfig, writeClientConfig];

        let vendorDirs = configutils.tryRead(buildConfig, ["vendor-dirs"], ["vendor"]);

        tasks.push({
            name: "build-browser-app", //build client js bundle
            plugin: builtInPlugins["build-browser-app"],
            options: {
                source: siteConfig.source,
                destination: siteConfig.destination,
                clientBuildDirectory: siteConfig["dir-dev-build"],
                appEntryPoint: siteConfig["app-entry-point"],
                bundleName: siteConfig["dev-bundle-name"],
                extensions: ["js", "jsx", "json"],
                changeExtensions: configutils.tryRead(buildConfig, ["tasks", "build-browser-app", "change-extensions"], [{ to: "js", from: ["jsx"] }]),
                debug: true,
                globalModules: configutils.tryRead(buildConfig, ["tasks", "build-browser-app", "global-modules"], []),
                excludedModules: configutils.tryRead(buildConfig, ["tasks", "build-browser-app", "excluded-modules"], []),
                excludedDirectories: [siteConfig.destination]
                    .concat(configutils.tryRead(buildConfig, ["tasks", "build-browser-app", "excluded-patterns"], []))
                    .concat(vendorDirs)
                    .concat(siteConfig["excluded-dirs"]),
                excludedPatterns: siteConfig["excluded-patterns"],
                buildSpecificJSSuffix: siteConfig["override-js-suffix"],
                originalJSSuffix: siteConfig["original-js-suffix"],
                excludedWatchPatterns: siteConfig.builds["client-debug"]["override-js-suffix"] ? [new RegExp(`${siteConfig.builds["client-debug"]["override-js-suffix"]}\.(js|json)$`)] : [],
                blacklist: configutils.tryRead(buildConfig, ["tasks", "build-browser-app", "es6-transpile", "blacklist"], [])
            }
        });

        tasks.push({
            name: "load-data",
            plugin: builtInPlugins["load-data"],
            options: {
                data: data,
                collections: siteConfig.collections || {},
                collectionRootDirectory: siteConfig["collections-root-dir"] || "",
                dataDirectories: siteConfig["data-dirs"] || [],
                scavengeCollection: siteConfig["scavenge-collection"] || "",
                excludedDirectories: configutils.tryRead(buildConfig, ["tasks", "load-data", "excluded-directories"], ["node_modules"]),
                excludedFiles: configutils.tryRead(buildConfig, ["tasks", "load-data", "excluded-files"], ["config.yml", "config.yaml", "config.json"]),
                markdownExtensions: configutils.tryRead(buildConfig, ["tasks", "load-data", "markdown-extensions"], ["md", "markdown"])
            }
        });

        return tasks;
    },
    function*() {
        var filename = configutils.tryRead(buildConfig, ["data-filename"], "data.json");
        let dataFilePath = path.join(siteConfig.destination, siteConfig["dir-dev-build"], filename);

        if (yield* fsutils.exists(original)) {
            let renamed = original.replace(/\.js$/, `${options.originalJSSuffix}.${extension}`);
            let originalContents = yield* fsutils.readFile(original);
            yield* fsutils.writeFile(renamed, originalContents);
        }
    }
);

export default build;
