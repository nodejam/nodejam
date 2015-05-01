import path from "path";
import fsutils from "../../../utils/fs";
import configutils from "../../../utils/config";
import { getLogger } from "../../../utils/logging";
import getCommonTasks from "../build-utils/common-tasks";
import getStandardBuild from "../build-utils/standard-build";
import optimist from "optimist";
import mongoBackend from "ceramic-backend-mongodb";

let argv  = optimist.argv;

let data = {};

let build = getStandardBuild(
    "create-database",
    function*(siteConfig, builtInPlugins) {

        if (process.env.NODE_ENV === "production") {
            throw new Error("This build cannot be run when NODE_ENV is set to production.");
        }

        let { getLoadDataTask } = getCommonTasks("create-database", siteConfig, builtInPlugins);

        let tasks = [
            getLoadDataTask({
                name: "load-data",
                data: data
            })
        ];

        return tasks;
    },
    function*() {
        var db = argv.db;

        if (db) {
            let mongoDb = yield* mongoBackend.MongoClient.connect({database: db});
            for(let coll in data) {
                var mongoCollection = yield* mongoDb.collection(coll);
                yield* mongoCollection.insertMany(data[coll]);
            }
            yield* mongoDb.close();
        } else {
            throw new Error("Specify the name of the db with the --db parameter.");
        }
    }
);

export default build;
