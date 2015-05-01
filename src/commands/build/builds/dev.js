import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";

let data = {};

let build = getStandardBuild(
    "dev",
    function*(siteConfig, builtInPlugins) {
        let { getTranspileServerTask, getLessTask, getCopyStaticFilesTask, getWriteConfigTask, getBuildClientTask, getLoadDataTask } = getCommonTasks("dev", siteConfig, builtInPlugins);

        let buildConfigReader = configutils.getReader(siteConfig, ["builds", "dev"]);
        let browserBuildFileSuffix = buildConfigReader(["browser-build-file-suffix"], "~dev");
        let browserReplacedFileSuffix = buildConfigReader(["browser-replaced-file-suffix"], "_base");

        let tasks = [
            getTranspileServerTask({
                name: "transpile-server"
            }),
            getLessTask({
                name: "less"
            }),
            getCopyStaticFilesTask({
                name: "copy-static-files",
                destination: siteConfig.destination
            }),
            getWriteConfigTask({
                name: "write-config",
                destination: siteConfig.destination
            }),
            getWriteConfigTask({
                name: "write-client-config",
                destination: buildConfigReader(["client-build-dir"], "js")
            }),
            getBuildClientTask({
                name: "build-browser-app",
                browserBuildFileSuffix,
                browserReplacedFileSuffix,
                debug: true,
                dependencies: ["load-data"]
            }),
            getLoadDataTask({
                name: "load-data",
                data: data
            }),
            {
                build: true,
                fn: function() {
                    this.job(
                        function*() {
                            let buildConfigReader = configutils.getReader(siteConfig, ["builds", "dev"]);
                            var filename = buildConfigReader(["data-filename"], "data.json");
                            let devBuildDir = buildConfigReader(["dev-build-dir"], "js");
                            yield* fsutils.writeFile(path.join(siteConfig.destination, devBuildDir, filename), JSON.stringify(data));
                        },
                        "write-static-data",
                        ["load-data"]
                    );
                }
            }
        ];

        return tasks;
    }
);

export default build;
