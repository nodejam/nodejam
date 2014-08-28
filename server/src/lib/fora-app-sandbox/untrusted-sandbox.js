(function() {
    "use strict";

    var _;


    var UntrustedSandbox = function(app, extensionModule) {
        this.app = app;
        this.extensionModule = extensionModule;
    };


    UntrustedSandbox.prototype.executeRequest = function*(requestContext) {        
    };


    module.exports = UntrustedSandbox;

})();
