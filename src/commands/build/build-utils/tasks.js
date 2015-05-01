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
    let build = crankshaft.create();

    build.configure(function() {
        for (let task of tasks) {
            var runnable = (task.plugin) ? task.plugin(task.name, (task.options || {})) : task;
            runnable.call(this);
        }
    }, dir);

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
