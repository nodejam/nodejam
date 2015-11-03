import path from "path";
import optimist from "optimist";
import tools from "crankshaft-tools";
import fsutils from "../utils/fs";
import { print, getLogger } from "../utils/logging";
import cli from "../utils/cli";

const argv = optimist.argv;


const printSyntax = (msg) => {
    if (msg) {
        print(`Error: ${msg}`);
    }
    print(`Usage: fora install <template_name> [--git]`);
    process.exit();
};


const getArgs = function() {
    const args = cli.getArgs();

    if (args.length < 4) {
        printSyntax();
    }
    /* params */
    const template = args[3];
    return { template };
};


const install = async function() {
    const HOME_DIR = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
    const templatesDir = path.join(HOME_DIR, ".fora", "templates");
    const nodeModulesDir = path.join(templatesDir, "node_modules");

    //Make sure ~/.fora/templates/node_modules exists
    if (!(await fsutils.exists(nodeModulesDir))) {
        await fsutils.mkdirp(nodeModulesDir);
    }

    const _shellExec = tools.process.spawn({ stdio: "inherit" });
    const shellExec = async function(cmd) {
        await _shellExec("sh", ["-c", cmd]);
    };

    if (argv.git) {
        process.chdir(nodeModulesDir);
        const templateUrl = getArgs().template;
        const urlParts = templateUrl.split("/");
        const template = urlParts[urlParts.length - 1];
        const destDir = path.join(nodeModulesDir, template);
        if (await fsutils.exists(destDir)) {
            print(`${destDir} exists. Will git pull.`);
            process.chdir(template);
            await shellExec(`git pull`);
        } else {
            print(`Cloning to ${destDir}.`);
            await shellExec(`git clone ${templateUrl}`);
            process.chdir(template);
            await shellExec(`npm install`);
        }
    } else {
        const { template } = getArgs();
        print(`Installing ${template} with npm. This make take a few minutes.`);
        process.chdir(templatesDir);
        await shellExec(`npm install ${template}`);
    }
};

export default install;
