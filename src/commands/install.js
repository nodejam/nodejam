import optimist from "optimist";
import tools from "crankshaft-tools";
import fsutils from "../utils/fs";
import { print, getLogger } from "../utils/logging";
import path from "path";

let argv = optimist.argv;


let printSyntax = (msg) => {
    if (msg) {
        print(`Error: ${msg}`);
    }
    print(`Usage: fora install <template_name> [--git]`);
    process.exit();
};


let getParams = function() {
    let args = process.argv.filter(a => !/^-/.test(a));

    if (args.length < 4) {
        printSyntax();
    }
    /* params */
    let template = args[3];
    return { template };
};


let install = function*() {
    let HOME_DIR = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
    let templatesDir = path.join(HOME_DIR, ".fora", "templates");
    let nodeModulesDir = path.join(templatesDir, "node_modules");

    //Make sure ~/.fora/templates/node_modules exists
    if (!(yield* fsutils.exists(nodeModulesDir))) {
        yield* fsutils.mkdirp(nodeModulesDir);
    }

    let exec = tools.process.exec();

    if (argv.git) {
        process.chdir(nodeModulesDir);
        let templateUrl = getParams().template;
        let urlParts = templateUrl.split("/");
        let template = urlParts[urlParts.length - 1];
        let destDir = path.join(nodeModulesDir, template);
        if (yield* fsutils.exists(destDir)) {
            print(`${destDir} exists. Will git pull.`);
            process.chdir(template);
            print(yield* exec(`git pull`));
        } else {
            print(`Cloning to ${destDir}.`);
            print(yield* exec(`git clone ${templateUrl}`));
            process.chdir(template);
            print(yield* exec(`npm install`));
        }
    } else {
        let { template } = getParams();
        print(`Installing ${template} with npm. This make take a few minutes.`);
        process.chdir(templatesDir);
        print(yield* exec(`npm install ${template}`));
    }
};

export default install;
