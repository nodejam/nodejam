import optimist from "optimist";

const argv = optimist.argv;

const isEmpty = function(val) {
    return typeof val === "undefined" || val === null;
};

/*
    Tries to read a.b.c.d when passed a, ["b", "c", "d"]
    If anything is undefined, returns defaultVal
*/
const tryRead = function(obj, path, defaultVal) {
    let currentVal = obj;
    for (let i = 0; i < path.length; i++) {
        const p = path[i];
        if (typeof currentVal[p] !== "undefined") {
            currentVal = currentVal[p];
        } else {
            if (typeof defaultVal !== "undefined") {
                return defaultVal;
            } else {
                throw new Error(`${path.join(".")} is mandatory in ${JSON.stringify(obj)}`);
            }
        }
    }
    return currentVal;
};


const getReader = function(obj, defaultPath) {
    return function(remainingPath, defaultValue) {
        return tryRead(obj, defaultPath.concat(remainingPath), defaultValue);
    };
};


const getProperty = function(config, fullyQualifiedProperty) {
    //props are like "a.b.c"; we need to find config.a.b.c
    //propParent will be config.a.b, in this case.
    const propArray = fullyQualifiedProperty.split(".");
    const propertyName = propArray.slice(propArray.length - 1)[0];
    const propParents = propArray.slice(0, propArray.length - 1);

    //Make sure a.b exists in config
    let parentProperty = config;

    for (let parent of propParents) {
        if (isEmpty(parentProperty[parent])) {
            parentProperty[parent] = {};
        }
        parentProperty = parentProperty[parent];
    }

    return { propertyName, parentProperty };
};




/*
    getValueSetter() returns a valueSetter function.
    valueSetter initializes config properties with
        a) command-line params, if specified
        b) default values, if property is currently empty
*/
const getValueSetter = function(config) {
    return (fullyQualifiedProperty, defaultValue, options = {}) => {
        const { propertyName, parentProperty } = getProperty(config, fullyQualifiedProperty);

        if (isEmpty(parentProperty[propertyName])) {
            parentProperty[propertyName] = defaultValue;
        } else {
            if (options.replace) {
                parentProperty[propertyName] = defaultValue;
            }
        }
    };
};


const commandLineSetter = function(config) {
    for (let cmd in argv) {
        let isArray = false;
        if (cmd !== "_" && !(/^\$/.test(cmd)) && ["s", "d", "source", "destination"].indexOf(cmd) === -1) {
            if (/\[\]$/.test(cmd)) {
                cmd = cmd.replace(/\[\]$/, "");
                isArray = true;
            }

            const { propertyName, parentProperty } = getProperty(config, cmd);

            const commandLineValue = argv[cmd];
            if (!isEmpty(commandLineValue)) {
                if (isEmpty(parentProperty[propertyName])) {
                    parentProperty[propertyName] = isArray ? [].concat(commandLineValue) : commandLineValue;
                } else {
                    //If current prop is not empty, but is an array, replace if
                    // flag is set. Otherwise concat.
                    if (parentProperty[propertyName] instanceof Array) {
                        if (argv[fullyQualifiedProperty + "-replace"]) {
                            parentProperty[propertyName] = [].concat(commandLineValue);
                        } else {
                            parentProperty[propertyName] = parentProperty[propertyName].concat(commandLineValue);
                        }
                    } else {
                        //If current prop is not an array, replace anyway.
                        parentProperty[propertyName] = isArray ? [].concat(commandLineValue) : commandLineValue;
                    }
                }
            }
        }
    }
};


/*
    example of obj:
    {
        prop1: false,
        prop2: "hello",
        prop3: { value: ["A"], options: { replace: true } }
        prop4: {
            propInner1: 100
        }
    }

    returns [
        ["prop1", false],
        ["prop2", "hello"],
        ["prop3", "A", { replace: true}],
        ["prop4.propInner", 1000]
    ]
}
*/
const getFullyQualifiedProperties = function(obj, prefixes = [], acc = []) {
    for (let key in obj) {
        const val = obj[key];
        const fullNameArray = prefixes.concat(key);
        if (!(val instanceof Array) && val !== null && typeof val === "object" && (typeof val.value === "undefined")) {
            acc.push([fullNameArray.join("."), {}]);
            getFullyQualifiedProperties(val, fullNameArray, acc);
        } else {
            if (val && typeof val.value !== "undefined") {
                acc.push([fullNameArray.join("."), val.value, val]);
            } else {
                acc.push([fullNameArray.join("."), val]);
            }
        }
    }
    return acc;
};



export default { tryRead, getReader, getValueSetter, commandLineSetter, getFullyQualifiedProperties };
