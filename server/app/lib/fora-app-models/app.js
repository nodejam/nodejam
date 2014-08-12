(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var models = require('./'),
        AppBase = require('./app-base').AppBase,
        typeHelpers = require('fora-type-helpers');

    var conf = require('fora-configuration');

    //ctor
    var App = function() {
        AppBase.apply(this, arguments);
    };

    App.prototype = Object.create(AppBase.prototype);
    App.prototype.constructor = App;

    __extends(App, AppBase);


    App.typeDefinition = (function() {
        var originalDef = typeHelpers.clone(AppBase.typeDefinition);
        originalDef.discriminator = function*(obj, typesService) {
            var def = yield* typesService.getTypeDefinition(obj.type);
            if (def.ctor !== App)
                throw new Error("App type definitions must have ctor set to App");
            return def;
        };
        return originalDef;
    })();



    App.prototype.save = function*(context) {
        //if stub is a reserved name, change it
        if (!stub)
            throw new Error("Missing stub");

        if (conf.reservedNames.indexOf(this.stub) > -1)
            throw new Error("Stub cannot be " + stub + ", it is reserved");

        var regex = /[a-z][a-z0-9|-]*/;
        if (!regex.test(this.stub))
            throw new Error("Stub is invalid");

        return yield* AppBase.prototype.save.call(this, context);
    };

    exports.App = App;

})();
