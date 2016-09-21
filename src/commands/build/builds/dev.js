import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { print, getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";

const data = {};

const build = getStandardBuild(
  "dev",
  async function(siteConfig, builtInPlugins) {
    const { getTranspileServerTask, getLessTask, getCopyStaticFilesTask, getWriteConfigTask, getBuildClientTask, getLoadDataTask } = getCommonTasks("dev", siteConfig, builtInPlugins);

    const buildConfigReader = configutils.getReader(siteConfig, ["builds", "dev"]);
    const browserBuildFileSuffix = buildConfigReader(["browser-build-file-suffix"], "~dev");
    const browserReplacedFileSuffix = buildConfigReader(["browser-replaced-file-suffix"], "_base");

    const tasks = [
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
        dependencies: ["write-static-data"]
      }),
      getLoadDataTask({
        name: "load-data",
        data: data
      }),
      function() {
        this.job(
          async function() {
            const buildConfigReader = configutils.getReader(siteConfig, ["builds", "dev"]);
            const filename = buildConfigReader(["data-filename"], "data.json");
            const devBuildDir = buildConfigReader(["dev-build-dir"], "js");
            const outputPath = path.join(siteConfig.destination, devBuildDir, filename);
            await fsutils.ensureDirExists(outputPath);
            await fsutils.writeFile(outputPath, JSON.stringify(data));
          },
          "write-static-data",
          ["load-data"]
        );
      }
    ];

    return tasks;
  }
);

export default build;
