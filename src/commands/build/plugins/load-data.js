import path from "path";
import frontMatter from "front-matter";
import yaml from "js-yaml";
import fsutils from "../../../utils/fs";
import readFileByFormat from "../../../utils/file-reader";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";

let argv = optimist.argv;

/*
    options: {
        dataVariable: object,
        collections: {
            name1: { dir: string },
            name2: { dir: string }
        },
        collectionRootDirectory: string,
        dataDirectories: [string],
        scavengeCollection: string,
        excludedDirectories: [string],
        excludedFiles: [string],
        markdownExtensions: [string]
    }
*/
let loadStaticData = function(name, options) {
    let verboseMode = argv[`verbose-${name}`];
    let logger = getLogger(options.quiet, name || "load-static-data");

    var data = options.data;

    //Add a watch for each collection.
    let getCollectionLoader = function(collection) {
        return function*(filePath) {
            let extension = path.extname(filePath);

            try {
                let record = yield* readFileByFormat(filePath, { markdown: options.markdownExtensions });
                record.__filePath = filePath;

                if (record)
                    data[collection].push(record);
                    logger(`loaded ${filePath} into ${collection}`);
            } catch (ex) {
                logger(ex);
            }
        };
    };

    let fn = function() {
        //Data directories
        this.watch(
            ["yaml", "yml", "json"]
                .map(ext => options.dataDirectories.map(dir => `${dir}/*.${ext}`))
                .reduce((a,b) => a.concat(b)),
            function*(filePath) {
                let extension = path.extname(filePath);

                let records;
                try {
                    records = yield* readFileByFormat(filePath);

                    let filename = path.basename(filePath, extension);
                    if (records && records.length) {
                        data[filename] = data[filename] ? data[filename].concat(records) : records ;
                    }

                    logger(`loaded ${filePath} into ${filename}`);

                } catch (ex) {
                    logger(ex);
                }
            }
        );

        //Check the collection directories
        for (let collectionName in options.collections) {
            data[collectionName] = [];
            let collection = options.collections[collectionName];
            if (collection.dir) {
                let collectionDir = options.collectionRootDirectory ? path.combine(options.collectionRootDirectory, collection.dir) : collection.dir;
                this.watch(
                    options.markdownExtensions.concat(["json"]).map(ext => `${collectionDir}/*.${ext}`),
                    getCollectionLoader(collectionName)
                );
            }
        }

        //If scavenging is on, we need to pick up md and json files outside
        //  collection and data_dir and push them into the scavenge collection.
        if (options.scavengeCollection) {
            data[options.scavengeCollection] = [];

            let collectionsAndDataDirs = Object.keys(options.collections)
                .map(coll => options.collections[coll].dir)
                .filter(item => item)
                .concat(options.dataDirectories)
                .map(dir => `!${dir}/`);

            let exclusions = options.excludedDirectories.map(e => `!${e}/`)
                .concat(options.excludedFiles.map(e => `!${e}`))
                .concat(collectionsAndDataDirs);

            var filePatterns = options.markdownExtensions.concat(["json"]).map(ext => `*.${ext}`);

            this.watch(filePatterns.concat(exclusions),
                getCollectionLoader(options.scavengeCollection)
            );
        }
    };

    return { build: true, fn: fn };
};

export default loadStaticData;
