import tools from "crankshaft-tools";
import optimist from "optimist";
import path from "path";
import fsutils from "../utils/fs";
import { print, getLogger } from "../utils/logging";
import cli from "../utils/cli";

const argv = optimist.argv;


const printSyntax = (msg) => {
  if (msg) {
    print(`Error: ${msg}`);
  }
  print(`Usage: fora new <template> <project_name> [-d <destination>] [--recreate]`);
  process.exit();
};


const getArgs = function() {
  const args = cli.getArgs();

  if (args.length < 5) {
    printSyntax();
  }
  /* params */
  const template = args[3];
  const name = args[4].trim().replace(/\s+/g, '-').toLowerCase();
  return { template, name };
};


/*
Copy files from the template directory to the destination directory.
*/
const copyTemplateFiles = async function() {
  const logger = getLogger(argv.quiet || false);

  const { template, name } = getArgs();

  const destination = path.join((argv.d || argv.destination || "./"), name);
  const destinationExists = await fsutils.exists(destination);

  //Make sure the directory is empty or the recreate flag is on
  if (destinationExists && !argv.recreate) {
    print(`Conflict: ${path.resolve(destination)} is not empty. Delete the directory manually or use --recreate.`);
  } else {

    if (destinationExists) {
      if (argv.recreate) {
        print(`Deleting ${destination}`);
        await fsutils.remove(destination);
        await fsutils.mkdirp(destination);
      }
    } else {
      await fsutils.mkdirp(destination);
    }

    //Copy template
    const _shellExec = tools.process.spawn({ stdio: "inherit" });
    const shellExec = async function(cmd) {
      await _shellExec("sh", ["-c", cmd]);
    };
    const exec = tools.process.exec();

    const templatePath = await resolveTemplatePath(template);
    logger(`Copying ${templatePath} -> ${destination}`);
    await fsutils.copyRecursive(templatePath, destination, { forceDelete: true });

    //Install npm dependencies.
    const curdir = await exec(`pwd`);
    process.chdir(destination);
    await shellExec(`npm install`);
    process.chdir(curdir);

    //Let's overwrite package.json
    const packageJsonPath = path.join(destination, "package.json");
    const packageJson = await fsutils.readFile(packageJsonPath);
    const packageInfo = JSON.parse(packageJson);
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
    await fsutils.writeFile(path.join(destination, "package.json"), JSON.stringify(packageInfo, null, 4));

    print(`New ${template} site installed in ${path.resolve(destination)}.`);
  }
};


/*
Search paths are:
a) Current node_modules directory
b) ~/.fora/templates/node_modules
*/
const resolveTemplatePath = async function(name) {
  const templateName = /^fora-template-/.test(name) ? name : `fora-template-${name}`;

  //Current node_modules_dir
  const node_modules_templatePath = path.resolve(GLOBAL.__libdir, "../node_modules", name);
  const node_modules_prefixedTemplatePath = path.resolve(GLOBAL.__libdir, "../node_modules", `fora-template-${name}`);

  /*
  Templates can also be under
  ~/.fora/templates/example-template
  ~/.fora/templates/node_modules/example-template
  */
  const HOME_DIR = process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
  const HOME_templatePath = path.resolve(`${HOME_DIR}/.fora/templates`, name);
  const HOME_prefixedTemplatePath = path.resolve(`${HOME_DIR}/.fora/templates`, `fora-template-${name}`);
  const HOME_node_modules_templatePath = path.resolve(`${HOME_DIR}/.fora/templates/node_modules`, name);
  const HOME_node_modules_prefixedTemplatePath = path.resolve(`${HOME_DIR}/.fora/templates/node_modules`, `fora-template-${name}`);

  const paths = [
    node_modules_templatePath,
    node_modules_prefixedTemplatePath,
    HOME_templatePath,
    HOME_prefixedTemplatePath,
    HOME_node_modules_templatePath,
    HOME_node_modules_prefixedTemplatePath
  ];

  for (let templatePath of paths) {
    if (await fsutils.exists(templatePath)) {
      return templatePath;
    }
  }

  throw new Error(`Template "${name}" or "fora-template-${name}" was not found.`);
};


export default copyTemplateFiles;
