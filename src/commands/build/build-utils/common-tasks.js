import path from "path";
import configutils from "../../../utils/config";

const getCommonTasks = function(buildName, siteConfig, builtInPlugins) {

    /*
        This gives us all extensions which are build specific.
        eg ["~client", "~dev"]
    */
    const browserBuildFileSuffixes = Object.keys(siteConfig.builds)
        .map(key => siteConfig.builds[key]["browser-build-file-suffix"])
        .filter(suffix => typeof suffix !== "undefined" && suffix !== null);

    const excludedBuildSpecificFilePatterns = browserBuildFileSuffixes.map(s => `${s}\.(js|json)$`);

    const getTranspileServerTask = function(options) {
        const dependencies = options.dependencies;
        const destination = siteConfig.destination;
        const extensions = siteConfig["js-extensions"];
        const excludedPatterns = siteConfig["excluded-patterns"]
            .map(p => { return { exclude: p.exclude, regex: new RegExp(p.regex) }; });

        const taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        const vendorDirs = taskConfigReader(["vendor-dirs"], ["vendor"]);
        const excludedDirectories = [siteConfig.destination]
            .concat(vendorDirs)
            .concat(siteConfig["excluded-dirs"]);
        const blacklist = ["regenerator", "es6.constants", "es6.blockScoping"];

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

    const getLessTask = function(options) {
        const dependencies = options.dependencies;
        const destination = siteConfig.destination;

        const taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        const directories = taskConfigReader(["dirs"], ["css"]);

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


    const getCopyStaticFilesTask = function(options) {
        const dependencies = options.dependencies;
        const destination = options.destination;
        const extensions = options.extensions || ["*.*"];
        const excludedDirectories = [siteConfig.destination]
            .concat(siteConfig["excluded-dirs"]);
        const excludedPatterns = siteConfig["excluded-patterns"];

        const taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        const excludedExtensions = taskConfigReader(["excluded-extensions"], ["less"]);
        const changeExtensions = taskConfigReader(["change-extensions"], [{ to: "js", from: ["jsx"] }]);

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


    const getWriteConfigTask = function(options) {
        const dependencies = options.dependencies;
        const destination = path.join(siteConfig.destination);

        const taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        const filename = taskConfigReader(["filename"], "config.json");

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


    const getBuildClientTask = function(options) {
        const dependencies = options.dependencies;
        const excludedDirectories = siteConfig["excluded-dirs"].concat(siteConfig["custom-builds-dir"], siteConfig["custom-tasks-dir"]);
        const excludedPatterns = siteConfig["excluded-patterns"];
        const changeExtensions = siteConfig["change-extensions"];
        const jsExtensions = siteConfig["js-extensions"].concat("json");

        const buildConfigReader = configutils.getReader(siteConfig, ["builds", buildName]);
        const taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        const vendorDirs = taskConfigReader(["vendor-dirs"], ["vendor"]);
        const clientBuildDirectory = options.clientBuildDirectory || buildConfigReader(["client-build-dir"], "js");
        const appEntryPoint = taskConfigReader(["entry-point"], "app.js");
        const bundleName = taskConfigReader(["bundle-name"], "app.bundle.js");
        const globalModules = options.globalModules || taskConfigReader(["global-modules"], []);
        const excludedModules = options.excludedModules || taskConfigReader(["excluded-modules"], []);
        const browserBuildFileSuffix = options.browserBuildFileSuffix;
        const browserReplacedFileSuffix = options.browserReplacedFileSuffix;
        const blacklist = taskConfigReader(["es6-transpile", "blacklist"], []);

        const excludedWatchPatterns = taskConfigReader(["excluded-watch-patterns"], [browserBuildFileSuffixes.filter(s => s !== browserBuildFileSuffix)])
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

    const getLoadDataTask = function(options) {
        const dependencies = options.dependencies;
        const scavengeCollectionDependencies = options.scavengeCollectionDependencies;
        const collectionLoaderDependencies = options.collectionLoaderDependencies;
        const collections = siteConfig.collections;
        const collectionRootDirectory = siteConfig["collections-root-dir"];
        const dataDirectories = siteConfig["data-dirs"];
        const scavengeCollection = siteConfig["scavenge-collection"] || "posts";

        const buildConfigReader = configutils.getReader(siteConfig, ["builds", buildName]);
        const taskConfigReader = configutils.getReader(siteConfig, ["builds", buildName, "tasks", options.name]);

        const vendorDirs = taskConfigReader(["vendor-dirs"], ["vendor"]);
        const excludedDirectories = siteConfig["excluded-dirs"].concat([siteConfig["custom-builds-dir"], siteConfig["custom-tasks-dir"]]).concat(vendorDirs);

        const excludedFiles = taskConfigReader(["excluded-files"], ["config.yml", "config.yaml", "config.json", "package.json", "README.md"]);
        const markdownExtensions = taskConfigReader(["markdown-extensions"], ["md", "markdown"]);

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
