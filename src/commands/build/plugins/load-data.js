import path from "path";
import frontMatter from "front-matter";
import yaml from "js-yaml";
import fsutils from "../../../utils/fs";
import readFileByFormat from "../../../utils/file-reader";
import { print, getLogger } from "../../../utils/logging";
import optimist from "optimist";

const argv = optimist.argv;

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
const loadStaticData = function(name, options) {
    const verboseMode = argv[`verbose-${name}`];
    const logger = getLogger(options.quiet, name || "load-static-data");

    const data = options.data;

    //Add a watch for each collection.
    const getCollectionLoader = function(collection) {
        return async function(filePath) {
            const extension = path.extname(filePath);

            try {
                logger(`Loading ${filePath} into ${collection}`);

                const record = await readFileByFormat(filePath, { markdown: options.markdownExtensions });
                record.__filePath = filePath;

                if (record) {
                    data[collection].push(record);
                }

            } catch (ex) {
                logger(ex);
            }
        };
    };

    return function() {
        //Data directories
        this.watch(
            ["yaml", "yml", "json"]
                .map(ext => options.dataDirectories.map(dir => `${dir}/*.${ext}`))
                .reduce((a,b) => a.concat(b)),
            async function(filePath) {
                const extension = path.extname(filePath);

                try {
                    const records = await readFileByFormat(filePath);
                    const filename = path.basename(filePath, extension);

                    logger(`Loading ${filePath} into ${filename}`);

                    if (records && records.length) {
                        data[filename] = data[filename] ? data[filename].concat(records) : records ;
                    }
                } catch (ex) {
                    logger(ex);
                }
            },
            name,
            options.dependencies || []
        );

        //Check the collection directories
        for (let collectionName in options.collections) {
            data[collectionName] = [];
            const collection = options.collections[collectionName];
            if (collection.dir) {
                const collectionDir = options.collectionRootDirectory ? path.combine(options.collectionRootDirectory, collection.dir) : collection.dir;
                this.watch(
                    options.markdownExtensions.concat(["json"]).map(ext => `${collectionDir}/*.${ext}`),
                    getCollectionLoader(collectionName),
                    `${name}-collection-loader`,
                    options.collectionLoaderDependencies || []
                );
            }
        }

        //If scavenging is on, we need to pick up md and json files outside
        //  collection and data_dir and push them into the scavenge collection.
        if (options.scavengeCollection) {
            data[options.scavengeCollection] = [];

            const collectionsAndDataDirs = Object.keys(options.collections)
                .map(coll => options.collections[coll].dir)
                .filter(item => item)
                .concat(options.dataDirectories)
                .map(dir => `!${dir}/`);

            const exclusions = options.excludedDirectories.map(e => `!${e}/`)
                .concat(options.excludedFiles.map(e => `!${e}`))
                .concat(collectionsAndDataDirs);

            const filePatterns = options.markdownExtensions.concat(["json"]).map(ext => `*.${ext}`);

            this.watch(
                filePatterns.concat(exclusions),
                getCollectionLoader(options.scavengeCollection),
                `${name}-scavenge-collection`,
                options.scavengeCollectionDependencies || []
            );
        }
    };
};

export default loadStaticData;
