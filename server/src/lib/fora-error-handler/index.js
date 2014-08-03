(function() {
    "use strict";

    var argv = require('optimist').argv;

    module.exports = function*(next) {
        try {
            yield* next;
        } catch (err) {
            var printer = argv['show-errors'] ? console.log : console.error;
            printer.call(console, err);
            printer.call(console, err.stack);
            if(err._inner) {
                printer.call(console, err._inner);
                printer.call(console, err._inner.stack);
            }
        }
    };

})();
