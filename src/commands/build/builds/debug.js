import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { print, getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";

const build = getStandardBuild(
  "debug",
  async function(siteConfig, builtInPlugins) {
    const { getTranspileServerTask, getLessTask, getCopyStaticFilesTask, getWriteConfigTask, getBuildClientTask } = getCommonTasks("debug", siteConfig, builtInPlugins);

    const buildConfigReader = configutils.getReader(siteConfig, ["builds", "debug"]);
    const browserBuildFileSuffix = buildConfigReader(["browser-build-file-suffix"], "~client");
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
        debug: true
      })
    ];

    return tasks;
  }
);

export default build;
