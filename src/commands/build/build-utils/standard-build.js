import { getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
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

let getStandardBuild = function(buildName, fn, cbOnComplete) {
    return function*(siteConfig, builtInPlugins, buildUtils) {

        let tasks = yield* fn(siteConfig,builtInPlugins, buildUtils);

        let startTime = Date.now();

        let { runTasks, getCustomTasks } = buildUtils.tasks;

        let logger = getLogger(siteConfig.quiet, buildName);

        let customTasks = yield* getCustomTasks(siteConfig, builtInPlugins, buildUtils);

        if (customTasks)
            yield* buildUtils.tasks.runTasks(customTasks["on-start"]);

        let onComplete = function*() {
            if (customTasks)
                yield* buildUtils.tasks.runTasks(customTasks["on-complete"]);

            if (cbOnComplete) {
                yield* cbOnComplete();
            }

            let endTime = Date.now();
            logger(`Build ${buildName} took ${(endTime - startTime)/1000} seconds.`);
        };

        try {
            yield* buildUtils.tasks.runTasks(tasks, siteConfig.source, onComplete, siteConfig.watch);
        } catch (ex) {
            console.log(ex);
            console.log(ex.stack);
        }
    };
};

export default getStandardBuild;
