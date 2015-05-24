import fsutils from "./fs";
import path from "path";

let getVersion = function*() {
    let packageFile = path.resolve(__dirname, "../../package.json");
    let pkg = JSON.parse(yield* fsutils.readFile(packageFile));
    return pkg.version;
};

export default { getVersion: getVersion };
