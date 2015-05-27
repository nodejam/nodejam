import tools from "crankshaft-tools";
import optimist from "optimist";
import path from "path";
import fsutils from "../utils/fs";
import { print, getLogger } from "../utils/logging";
import cli from "../utils/cli";

let argv = optimist.argv;


let printSyntax = (msg) => {
    if (msg) {
        print(`Error: ${msg}`);
    }
    print(`Usage: fora new <template> <project_name> [-d <destination>] [--force] [--recreate]`);
    process.exit();
};


let getArgs = function() {
    var args = cli.getArgs();

    if (args.length < 5) {
        printSyntax();
    }
    /* params */
    let template = args[3];
    let name = args[4].trim().replace(/\s+/g, '-').toLowerCase();
    return { template, name };
};


/*
    Copy files from the template directory to the destination directory.
*/
let copyTemplateFiles = function*() {
    let logger = getLogger(argv.quiet || false);

    let { template, name } = getArgs();

    let destinationRoot = argv.d || argv.destination || "./";
    let destination = path.join(destinationRoot, name);

    //Make sure the directory is empty or the force flag is on
    if (!argv.force && !argv.recreate && !(yield* fsutils.empty(destination))) {
        print(`Conflict: ${path.resolve(destination)} is not empty.`);
    } else {

        if (argv.recreate) {
            if (yield* fsutils.exists(destination)) {
                print(`Deleting ${destination}`);
                yield* fsutils.remove(destination);
            }
        }

        //Copy template
        var _shellExec = tools.process.spawn({ stdio: "inherit" });
        let shellExec = function*(cmd) {
            yield* _shellExec("sh", ["-c", cmd]);
        };
        let exec = tools.process.exec();

        let templatePath = yield* resolveTemplatePath(template);
        logger(`Copying ${templatePath} -> ${destination}`);
        yield* fsutils.copyRecursive(templatePath, destination, { forceDelete: true });

        //Install npm dependencies.
        let curdir = yield* exec(`pwd`);
        process.chdir(destination);
        yield* shellExec(`npm install`);
        process.chdir(curdir);

        //Let's overwrite package.json
        let packageJsonPath = path.join(destination, "package.json");
        let packageJson = yield* fsutils.readFile(packageJsonPath);
        let packageInfo = JSON.parse(packageJson);
        packageInfo.name = name;
        packageInfo.description = argv["set-package-description"] || "Description for your project";
        packageInfo.version = argv["set-package-version"] || "0.0.1";
        packageInfo.homepage = argv["set-package-homepage"] || "Your home page";
        packageInfo.repository = {
            type: argv["set-package-repository-type"] || "git",
            url: argv["set-package-repository-url"] || "https://example.com/your/repository/path"
        };
        packageInfo.author = argv["set-package-author"] || "Your name";
        packageInfo.email = argv["set-package-email"] || "youremail@example.com";
        packageInfo.bugs = argv["set-package-bugs"] || "http://www.example.com/bugzilla/your-project";
        yield* fsutils.writeFile(path.join(destination, "package.json"), JSON.stringify(packageInfo, null, 4));

        print(`New ${template} site installed in ${path.resolve(destination)}.`);
    }
};


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


export default copyTemplateFiles;
