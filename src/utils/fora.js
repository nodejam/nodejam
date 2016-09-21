import fsutils from "./fs";
import path from "path";

const getVersion = async function() {
  const packageFile = path.resolve(__dirname, "../../package.json");
  const pkg = JSON.parse(await fsutils.readFile(packageFile));
  return pkg.version;
};

export default { getVersion };
