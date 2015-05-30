import fsutils from "./fs";
import path from "path";

const getVersion = function*() {
    const packageFile = path.resolve(__dirname, "../../package.json");
    const pkg = JSON.parse(yield* fsutils.readFile(packageFile));
    return pkg.version;
};

export default { getVersion: getVersion };
