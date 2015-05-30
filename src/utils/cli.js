const getArgs = function() {
    var args = [];
    for (let arg of process.argv) {
        if (/^-/.test(arg)) {
            break;
        } else {
            args.push(arg);
        }
    }
    return args;
};

export default { getArgs };
