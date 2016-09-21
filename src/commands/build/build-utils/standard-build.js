import { print, getLogger } from "../../../utils/logging";
import { runTasks, getCustomTasks } from "./tasks";
import builtInPlugins from "../plugins";
/*
  Hookable Build Pipeline Events
  ------------------------------
  To hook these events, place plugins in the following directory names
  under the dir_custom_tasks/production directory. Main tasks should not be under a specific
  sub-directory.

  - on-start
  - on-complete

  example: dir_custom_tasks/production/on-start/*.js will be run "on start".
*/

const getStandardBuild = function(buildName, fn, cbOnComplete) {
  return async function(siteConfig) {

    const tasks = await fn(siteConfig, builtInPlugins);

    const startTime = Date.now();

    const logger = getLogger(siteConfig.quiet, buildName);

    const customTasks = await getCustomTasks(siteConfig, builtInPlugins);

    if (customTasks)
    await runTasks(customTasks["on-start"]);

    const onComplete = async function() {
      if (customTasks)
      await runTasks(customTasks["on-complete"]);

      if (cbOnComplete) {
        await cbOnComplete(siteConfig);
      }

      const endTime = Date.now();
      logger(`Build ${buildName} took ${(endTime - startTime)/1000} seconds.`);
    };

    try {
      await runTasks(tasks, siteConfig.source, onComplete, siteConfig.watch);
    } catch (ex) {
      console.log(ex);
      console.log(ex.stack);
    }
  };
};

export default getStandardBuild;
