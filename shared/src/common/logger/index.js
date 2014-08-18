(function() {
    "use strict";

    var printError = function(err) {
        if (err) {
            log(err.stack || 'There is no stack trace.');
        } else {
            log('Error is null or undefined.');
        }
    };


    var printStack = function() {
        var err = new Error();
        log(err.stack());
    };


    var log = function(msg) {
        console.log(msg);
    };


    module.exports = {
        log: log,
        printError: printError,
        printStack: printStack
    };

})();
