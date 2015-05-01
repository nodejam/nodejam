import crankshaft from "crankshaft";
import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";

/*
    Parameters:
    ----------
    tasks = [
        {
            name: "transpile-custom-builds-and-plugins",
            plugin: builtInPlugins.babel,
            options: {
               source: buildRoot,
               destination: path.resolve(siteConfig.destination, dir),
               extensions: siteConfig["js-extensions"],
               blacklist: ["regenerator"]
           }
       }
   ];
   dir: root director for the build
   onComplete: Callback when the build completes
   monitor: bool, keep monitoring the files?
*/
let runTasks = function*(tasks, dir, onComplete, monitor) {
    if (!(tasks instanceof Array))
        tasks = [tasks];

    let build = crankshaft.create();

    for (let task of tasks) {
        let plugin = task.plugin(task.name, (task.options || {}));

        if (plugin.build) {
            if (plugin.fn) {
                build.configure(plugin.fn, dir);
            }
        } else {
            if (plugin.fn) {
                yield* plugin.fn();
            }
        }
    }

    if (onComplete) {
        build.onComplete(onComplete);
    }

    yield* build.start(monitor);
};


/*
    Load customTasks from the config.dir_custom_tasks directory.
*/
let getCustomTasks = function*(siteConfig, builtInPlugins) {
    var tasksFile = path.resolve(siteConfig.destination, siteConfig["custom-tasks-dir"], `${siteConfig.build}.js`);

    if (yield* fsutils.exists(tasksFile)) {
        return require(taskPath)(siteConfig, builtInPlugins);
    }
};

export default { runTasks, getCustomTasks };
