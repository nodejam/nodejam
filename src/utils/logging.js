let print = function(what, prefix) {
    if (what || prefix) {
        let _log = function(x) {
            console.log(prefix ? `[${prefix}] ${x}` : x);
        };

        if (what instanceof Error) {
            _log(what);
            _log(what.stack);
            if (what._inner) {
                _log(what._inner);
                _log(what._inner.stack);
            }
        } else {
            _log(what);
        }
    }
};

let getLogger = function(quiet, prefix) {
    return function(what) {
        if (!quiet) {
            print(what, prefix);
        }
    };
};

export { print, getLogger };
