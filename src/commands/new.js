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
    let printSyntax = (msg) => {
        print(`Error: ${msg} eg: fora new -n <name> -t <template> -d <destination> [--force] [--recreate]`);
    };

    let logger = getLogger(argv.quiet || false);

    let name = (argv.name || argv.n || "").trim();
    if (!name) {
        printSyntax("You must specify a name for the project.");
        return;
    }

    let destinationRoot = argv.destination || argv.d || "";
    if (!destinationRoot) {
        printSyntax("You must specify a path.");
        return;
    }

    let dest = path.join(destinationRoot, name);

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

        //Let's overwrite package.json
        var packageJsonPath = path.join(dest, "package.json");
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
        yield* fsutils.writeFile(path.join(dest, "package.json"), JSON.stringify(packageInfo, null, 4));

        print(`New ${template} site installed in ${path.resolve(dest)}.`);
    }
};

export default copyTemplateFiles;
