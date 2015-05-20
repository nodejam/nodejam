import path from "path";
import configutils from "../../../utils/config";

let getCommonTasks = function(buildName, siteConfig, builtInPlugins) {

    /*
        This gives us all extensions which are build specific.
        eg ["~client", "~dev"]
    */
    let browserBuildFileSuffixes = Object.keys(siteConfig.builds)
        .map(key => siteConfig.builds[key]["browser-build-file-suffix"])
        .filter(suffix => typeof suffix !== "undefined" && suffix !== null);

    let excludedBuildSpecificFilePatterns = browserBuildFileSuffixes.map(s => `${s}\.(js|json)$`);

    let getTranspileServerTask = function(options) {
        let dependencies = options.dependencies;
        let destination = siteConfig.destination;
        let extensions = siteConfig["js-extensions"];
        let excludedPatterns = siteConfig["excluded-patterns"]
            .map(p => { return { exclude: p.exclude, regex: new RegExp(p.regex) }; });

        let taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        let vendorDirs = taskConfigReader(["vendor-dirs"], ["vendor"]);
        let excludedDirectories = [siteConfig.destination]
            .concat(vendorDirs)
            .concat(siteConfig["excluded-dirs"]);
        let blacklist = ["regenerator"];

        return {
            name: options.name, //babel transpile server files, blacklist (regenerator)
            plugin: builtInPlugins.babel,
            options: {
                destination,
                extensions,
                excludedDirectories,
                excludedPatterns,
                excludedWatchPatterns: excludedBuildSpecificFilePatterns,
                blacklist,
                dependencies
            }
        };
    };

    let getLessTask = function(options) {
        let dependencies = options.dependencies;
        let destination = siteConfig.destination;

        let taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        let directories = taskConfigReader(["dirs"], ["css"]);

        return {
            name: options.name, //compile less files
            plugin: builtInPlugins.less,
            options: {
                destination,
                directories,
                dependencies
            }
        };
    };


    let getCopyStaticFilesTask = function(options) {
        let dependencies = options.dependencies;
        let destination = options.destination;
        let extensions = options.extensions || ["*.*"];
        let excludedDirectories = [siteConfig.destination]
            .concat(siteConfig["excluded-dirs"]);
        let excludedPatterns = siteConfig["excluded-patterns"];

        let taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        let excludedExtensions = taskConfigReader(["excluded-extensions"], ["less"]);
        let changeExtensions = taskConfigReader(["change-extensions"], [{ to: "js", from: ["jsx"] }]);

        return {
            name: options.name,
            plugin: builtInPlugins["copy-static-files"],
            options: {
                destination,
                extensions,
                excludedDirectories,
                excludedPatterns,
                excludedExtensions,
                excludedWatchPatterns: excludedBuildSpecificFilePatterns,
                changeExtensions,
                dependencies
            }
        };
    };


    let getWriteConfigTask = function(options) {
        let dependencies = options.dependencies;
        let destination = path.join(siteConfig.destination);

        let taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        let filename = taskConfigReader(["filename"], "config.json");

        return {
            name: options.name,
            plugin: builtInPlugins["write-config"],
            options: {
                destination,
                filename,
                config: siteConfig,
                dependencies
            }
        };
    };


    let getBuildClientTask = function(options) {
        let dependencies = options.dependencies;
        let excludedDirectories = siteConfig["excluded-dirs"].concat(siteConfig["custom-builds-dir"], siteConfig["custom-tasks-dir"]);
        let excludedPatterns = siteConfig["excluded-patterns"];
        let changeExtensions = siteConfig["change-extensions"];
        let jsExtensions = siteConfig["js-extensions"].concat("json");

        let buildConfigReader = configutils.getReader(siteConfig, ["builds", buildName]);
        let taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        let vendorDirs = taskConfigReader(["vendor-dirs"], ["vendor"]);
        let clientBuildDirectory = options.clientBuildDirectory || buildConfigReader(["client-build-dir"], "js");
        let appEntryPoint = taskConfigReader(["entry-point"], "app.js");
        let bundleName = taskConfigReader(["bundle-name"], "app.bundle.js");
        let globalModules = options.globalModules || taskConfigReader(["global-modules"], []);
        let excludedModules = options.excludedModules || taskConfigReader(["excluded-modules"], []);
        let browserBuildFileSuffix = options.browserBuildFileSuffix;
        let browserReplacedFileSuffix = options.browserReplacedFileSuffix;
        let blacklist = taskConfigReader(["es6-transpile", "blacklist"], []);

        let excludedWatchPatterns = taskConfigReader(["excluded-watch-patterns"], [browserBuildFileSuffixes.filter(s => s !== browserBuildFileSuffix)])
            .map(e => new RegExp(`${e}\.(js|json)$`));

        return {
            name: options.name,
            plugin: builtInPlugins["build-browser-app"],
            options: {
                source: siteConfig.source,
                destination: siteConfig.destination,
                clientBuildDirectory,
                appEntryPoint,
                bundleName,
                jsExtensions,
                changeExtensions,
                debug: options.debug,
                globalModules,
                excludedModules,
                excludedDirectories: vendorDirs.concat(excludedDirectories),
                excludedPatterns,
                browserBuildFileSuffix,
                browserReplacedFileSuffix,
                excludedWatchPatterns,
                blacklist,
                dependencies
            }
        };
    };

    let getLoadDataTask = function(options) {
        let dependencies = options.dependencies;
        let scavengeCollectionDependencies = options.scavengeCollectionDependencies;
        let collectionLoaderDependencies = options.collectionLoaderDependencies;
        let collections = siteConfig.collections;
        let collectionRootDirectory = siteConfig["collections-root-dir"];
        let dataDirectories = siteConfig["data-dirs"];
        let scavengeCollection = siteConfig["scavenge-collection"] || "posts";

        let buildConfigReader = configutils.getReader(siteConfig, ["builds", buildName]);
        let taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        let vendorDirs = taskConfigReader(["vendor-dirs"], ["vendor"]);
        let excludedDirectories = siteConfig["excluded-dirs"].concat([siteConfig["custom-builds-dir"], siteConfig["custom-tasks-dir"]]).concat(vendorDirs);

        let excludedFiles = taskConfigReader(["excluded-files"], ["config.yml", "config.yaml", "config.json", "package.json", "README.md"]);
        let markdownExtensions = taskConfigReader(["markdown-extensions"], ["md", "markdown"]);

        return {
            name: options.name,
            plugin: builtInPlugins["load-data"],
            options: {
                data: options.data,
                collections,
                collectionRootDirectory,
                dataDirectories,
                scavengeCollection,
                excludedDirectories,
                excludedFiles,
                markdownExtensions,
                dependencies,
                scavengeCollectionDependencies,
                collectionLoaderDependencies
            }
        };
    };

    return { getTranspileServerTask, getLessTask, getCopyStaticFilesTask, getWriteConfigTask, getBuildClientTask, getLoadDataTask };
};

export default getCommonTasks;
