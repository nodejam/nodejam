import tools from "crankshaft-tools";
import optimist from "optimist";
import path from "path";
import fsutils from "../utils/fs";
import { print, getLogger } from "../utils/logging";

let argv = optimist.argv;

/*
    Search paths are:
        a) Current node_modules directory
        b) ~/.fora/templates/node_modules
*/
let resolveTemplatePath = function*(name) {
    let templateName = /^fora-template-/.test(name) ? name : `fora-template-${name}`;

    //Current node_modules_dir
    let node_modules_templatePath = path.resolve(GLOBAL.__libdir, "../node_modules", name);
    let node_modules_prefixedTemplatePath = path.resolve(GLOBAL.__libdir, "../node_modules", `fora-template-${name}`);

    /*
        Templates can also be under
            ~/.fora/templates/example-template
            ~/.fora/templates/node_modules/example-template
    */
    let HOME_DIR = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
    let HOME_templatePath = path.resolve(`${HOME_DIR}/.fora/templates`, name);
    let HOME_prefixedTemplatePath = path.resolve(`${HOME_DIR}/.fora/templates`, `fora-template-${name}`);
    let HOME_node_modules_templatePath = path.resolve(`${HOME_DIR}/.fora/templates/node_modules`, name);
    let HOME_node_modules_prefixedTemplatePath = path.resolve(`${HOME_DIR}/.fora/templates/node_modules`, `fora-template-${name}`);

    let paths = [
        node_modules_templatePath,
        node_modules_prefixedTemplatePath,
        HOME_templatePath,
        HOME_prefixedTemplatePath,
        HOME_node_modules_templatePath,
        HOME_node_modules_prefixedTemplatePath
    ];

    for (let templatePath of paths) {
        if (yield* fsutils.exists(templatePath)) {
            return templatePath;
        }
    }

    throw new Error(`Template "${name}" or "fora-template-${name}" was not found.`);
};


/*
    Copy files from the template directory to the destination directory.
*/
let copyTemplateFiles = function*() {
    let logger = getLogger(argv.quiet || false);

    let dest = argv.destination || argv.d || !(/^--/.test(process.argv[3])) ? process.argv[3] : "";
    if (!dest) {
        print("Error:  You must specify a path. eg: fora new <dir> [options..].");
        return;
    }

    //Make sure the directory is empty or the force flag is on
    if (!argv.force && !argv.recreate && !(yield* fsutils.empty(dest))) {
        print(`Conflict: ${path.resolve(dest)} is not empty.`);
    } else {

        if (argv.recreate) {
            if (yield* fsutils.exists(dest)) {
                print(`Deleting ${dest}`);
                yield* fsutils.remove(dest);
            }
        }

        //Copy template
        let exec = tools.process.exec();
        let template = argv.template || argv.t || "blog";
        let templatePath = yield* resolveTemplatePath(template);
        logger(`Copying ${templatePath} -> ${dest}`);
        yield* fsutils.copyRecursive(templatePath, dest, { forceDelete: true });

        //Install npm dependencies.
        let curdir = yield* exec(`pwd`);
        process.chdir(dest);
        let npmMessages = yield* exec(`npm install`);
        print(npmMessages);
        process.chdir(curdir);

        print(`New ${template} site installed in ${path.resolve(dest)}.`);
    }
};

export default copyTemplateFiles;
