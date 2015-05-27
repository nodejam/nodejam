import path from "path";
import optimist from "optimist";
import tools from "crankshaft-tools";
import fsutils from "../utils/fs";
import { print, getLogger } from "../utils/logging";
import cli from "../utils/cli";

let argv = optimist.argv;


let printSyntax = (msg) => {
    if (msg) {
        print(`Error: ${msg}`);
    }
    print(`Usage: fora install <template_name> [--git]`);
    process.exit();
};


let getArgs = function() {
    var args = cli.getArgs();

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

    var _shellExec = tools.process.spawn({ stdio: "inherit" });
    let shellExec = function*(cmd) {
        yield* _shellExec("sh", ["-c", cmd]);
    };

    if (argv.git) {
        process.chdir(nodeModulesDir);
        let templateUrl = getArgs().template;
        let urlParts = templateUrl.split("/");
        let template = urlParts[urlParts.length - 1];
        let destDir = path.join(nodeModulesDir, template);
        if (yield* fsutils.exists(destDir)) {
            print(`${destDir} exists. Will git pull.`);
            process.chdir(template);
            yield* shellExec(`git pull`);
        } else {
            print(`Cloning to ${destDir}.`);
            yield* shellExec(`git clone ${templateUrl}`);
            process.chdir(template);
            yield* shellExec(`npm install`);
        }
    } else {
        let { template } = getArgs();
        print(`Installing ${template} with npm. This make take a few minutes.`);
        process.chdir(templatesDir);
        yield* shellExec(`npm install ${template}`);
    }
};

export default install;
