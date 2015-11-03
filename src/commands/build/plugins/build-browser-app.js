import path from "path";
import fs from "fs";
import promisify from "nodefunc-promisify";
import fsutils from "../../../utils/fs";
import { tryRead } from "../../../utils/config";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";
import browserify from "browserify";
import babelify from "babelify";
import exposify from "exposify";

const argv = optimist.argv;

/*
    options: {
        source: string,
        destination: string,
        clientBuildDirectory: string,
        appEntryPoint: string,
        bundleName: string,
        jsExtensions: [string],
        debug: bool,
        globalModules: [string],
        excludedModules: [string],
        browserBuildFileSuffix: string,
        browserReplacedFileSuffix: string,
        blacklist: [string],
        excludedFiles: [string],
        excludedDirectories: [string],
        excludedPatterns: [regex or string],
        excludedWatchPatterns = [regex],
        quiet: bool
    }
*/

const buildClient = function(name, options) {
    const verboseMode = argv[`verbose-${name}`];
    const logger = getLogger(options.quiet, name || "build-browser-app");

    //defaults
    options.jsExtensions = options.jsExtensions || ["js", "jsx", "json"];
    options.excludedFiles = options.excludedFiles || [];
    options.excludedDirectories = (options.excludedDirectories || []).concat(options.destination);
    options.excludedPatterns = options.excludedPatterns || [];
    options.blacklist = options.blacklist || [];
    options.excludedWatchPatterns = options.excludedWatchPatterns || [];

    const excludedWatchPatterns = options.excludedWatchPatterns.map(r => new RegExp(r));

    //Copy file into destDir
    const copyFile = async function(filePath, root) {
        //Get the relative filePath by removing the monitored directory (options.source)
        const originalPath = path.join(root, filePath);
        const clientPath = path.join(options.destination, options.clientBuildDirectory, filePath);
        //We might have some jsx files. Switch extension to js.
        const pathWithFixedExtension = fsutils.changeExtension(clientPath, options.changeExtensions);

        if (verboseMode) {
            logger(`Copying ${filePath} to ${pathWithFixedExtension}`);
        }

        await fsutils.copyFile(originalPath, pathWithFixedExtension, { createDir: true });
    };

    return function() {
        const jsExtensions = options.jsExtensions.map(e => `*.${e}`);

        const excluded = options.excludedDirectories.map(dir => `!${dir}/`)
            .concat(options.excludedFiles.map(e => `!${e}`))
            .concat(options.excludedPatterns.map(e => { return { exclude: e.exclude, regex: new RegExp(e.regex) }; }));

        let clientSpecificFiles = [];

        this.watch(
            jsExtensions.concat(excluded),
            async function(filePath, ev, matches) {
                if (!excludedWatchPatterns.some(regex => regex.test(filePath))) {
                    const clientFileRegex = new RegExp(`${options.browserBuildFileSuffix}\.(js|json)$`);

                    if (clientFileRegex.test(filePath)) {
                        if (verboseMode) {
                            logger(`Found client-specific file ${filePath}`);
                        }
                        clientSpecificFiles.push(filePath);
                    }

                    await copyFile(filePath, this.root);
                } else {
                    if (verboseMode) {
                        logger(`Skipped ${filePath}`);
                    }
                }
            },
            name,
            options.dependencies || []
        );


        /*
            Rules:
                1. In the client build, filename~client.js will be moved to filename.js
                2. Original filename.js will then be renamed filename_base.js (_base is configurable via options.browserReplacedFileSuffix)
                3. filename~client.js will longer exist, since it was moved.

                The same rules apply for "dev", "test" and other builds.
        */
        const replaceFiles = async function(files) {
            for (let file of files) {
                const filePath = path.join(options.destination, options.clientBuildDirectory, file);

                const extension = /\.js$/.test(file) ? "js" : "json";
                const regex = new RegExp(`${options.browserBuildFileSuffix}\\.${extension}$`);

                const original = filePath.replace(regex, `.${extension}`);
                if (await fsutils.exists(original)) {
                    const renamed = original.replace(/\.js$/, `${options.browserReplacedFileSuffix}.${extension}`);

                    if (verboseMode) {
                        logger(`Moving original ${original} to ${renamed}`);
                    }

                    const originalContents = await fsutils.readFile(original);
                    await fsutils.writeFile(renamed, originalContents);
                }

                const overriddenContents = await fsutils.readFile(filePath);
                await fsutils.writeFile(original, overriddenContents);

                //Remove abc~client.js and abc~dev.js, as the case may be.
                if (verboseMode) {
                    logger(`Moved ${filePath} to ${original}`);
                }

                await fsutils.remove(filePath);

                if (verboseMode) {
                    logger(`Deleted ${filePath}`);
                }
            }
        };


        /*
            Create the client and dev builds with browserify.
            Take the entry point from options, which defaults to app.js
        */
        const browserifyFiles = async function() {
            const entry = path.join(options.destination, options.clientBuildDirectory, options.appEntryPoint);
            const output = path.join(options.destination, options.clientBuildDirectory, options.bundleName);

            if (verboseMode) {
                logger(`Browserify started: entry is ${entry}`);
            }

            let b = browserify([entry], { debug: options.debug });

            options.excludedModules.concat(Object.keys(options.globalModules)).forEach(function(e) {
                b = b.external(e);
            });

            const r = b.transform(babelify.configure({ blacklist: options.blacklist }), { global: true })
                .transform(exposify, { expose: options.globalModules, global: true })
                .bundle()
                .pipe(fs.createWriteStream(output));

            await promisify(function(cb) {
                r.on("finish", cb);
            })();
        };


        this.onComplete(async function() {
            //Make the client build
            await replaceFiles(clientSpecificFiles);
            await browserifyFiles();
            logger(`Wrote ${options.bundleName}`);
            clientSpecificFiles = [];
        });
    };
};

export default buildClient;
