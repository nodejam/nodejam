(function() {
    "use strict";

    var ValidationError = function(message, details) {
        Error.call(this, message);
        this.name = "ValidationError";
        this.details = details;
    };

    ValidationError.prototype = Object.create(Error.prototype);
    ValidationError.prototype.constructor = ValidationError;

    module.exports = ValidationError;
})();
