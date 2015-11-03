import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { print, getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";
import optimist from "optimist";
import mongoBackend from "ceramic-backend-mongodb";

const argv  = optimist.argv;
const data = {};

const build = getStandardBuild(
    "database",
    async function(siteConfig, builtInPlugins) {


        if (process.env.NODE_ENV === "production") {
            throw new Error("This build cannot be run when NODE_ENV is set to production.");
        }

        const { getLoadDataTask } = getCommonTasks("database", siteConfig, builtInPlugins);

        const tasks = [
            getLoadDataTask({
                name: "load-data",
                data: data
            })
        ];

        return tasks;
    },
    async function(siteConfig) {
        const logger = getLogger(siteConfig.quiet, "database");
        const db = argv.db;

        if (db) {
            const mongoDb = await mongoBackend.MongoClient.connect({database: db});
            for (let coll in data) {
                const mongoCollection = await mongoDb.collection(coll);
                if (data[coll].length) {
                    logger(`Inserting ${data[coll].length} records into ${coll}.`);
                    await mongoCollection.insertMany(data[coll]);
                } else {
                    logger(`${coll} has zero records. skipping.`);
                }
            }
            await mongoDb.close();
        } else {
            throw new Error("Specify the name of the db with the --db parameter.");
        }
    }
);

export default build;
