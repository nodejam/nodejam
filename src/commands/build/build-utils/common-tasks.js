import path from "path";
import configutils from "../../../utils/config";

var getCommonTasks = function(siteConfig, buildConfig, builtInPlugins, options) {

    var excludedJSSuffixes = [siteConfig["client-js-suffix"], siteConfig["dev-js-suffix"]].filter(e => typeof e === "string");
    var excludedWatchPatterns = excludedJSSuffixes.map(s => new RegExp(`${s}\.(js|json)$`));

    var transpileServer = {
        name: "transpile-server", //babel transpile server files, blacklist (regenerator)
        plugin: builtInPlugins.babel,
        options: {
            destination: siteConfig.destination,
            extensions: siteConfig["js-extensions"],
            excludedDirectories: [siteConfig.destination]
                .concat(siteConfig["dirs-client-vendor"])
                .concat(siteConfig["dirs-exclude"]),
            excludedPatterns: siteConfig["patterns-exclude"],
            excludedWatchPatterns: excludedWatchPatterns,
            blacklist: ["regenerator"]
        }
    };

    var less = {
        name: "less", //compile less files
        plugin: builtInPlugins.less,
        options: {
            destination: siteConfig.destination,
            directories: configutils.tryRead(buildConfig, ["tasks", "less", "dirs"], [])
        }
    };


    var copyStaticFiles = {
        name: "copy-static-files", //copy static funny .gifs
        plugin: builtInPlugins["copy-static-files"],
        options: {
            destination: siteConfig.destination,
            extensions: ["*.*"],
            excludedDirectories: [siteConfig.destination]
                .concat(siteConfig["dirs-exclude"]),
            excludedPatterns: siteConfig["patterns-exclude"],
            excludedExtensions: configutils.tryRead(buildConfig, ["tasks", "copy-static-files", "exclude-extensions"], ["less"]),
            excludedWatchPatterns: excludedWatchPatterns,
            changeExtensions: configutils.tryRead(buildConfig, ["tasks", "copy-static-files", "change-extensions"], [{ to: "js", from: ["jsx"] }])
        }
    };

    var writeConfig = {
        name: "write-config", //write the merged config file into the destination directory
        plugin: builtInPlugins["write-config"],
        options: {
            destination: path.join(siteConfig.destination, siteConfig["dir-client-build"]),
            filename: configutils.tryRead(buildConfig, ["tasks", "write-config", "filename"], "config.json"),
            config: siteConfig
        }
    };

    return { transpileServer, less, copyStaticFiles, writeConfig };
};

export default getCommonTasks;
