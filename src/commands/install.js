import optimist from "optimist";
import tools from "crankshaft-tools";
import fsutils from "../utils/fs";
import { print, getLogger } from "../utils/logging";
import path from "path";

let argv = optimist.argv;

let install = function*() {
    try {
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
            let templateUrl = argv.t || argv.template;
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
            process.chdir(templatesDir);
            let template = argv.t || argv.template || process.argv[3];
            print(yield* exec(`npm install ${template}`));
        }
    } catch(ex) {
        print(ex.toString());
        print(`
            Usage:
                fora install -t <template_name>
                or
                fora install --git -t <git_url>
        `);

    }
};

export default install;
