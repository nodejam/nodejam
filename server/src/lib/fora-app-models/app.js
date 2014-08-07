(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var models = require('./'),
        AppBase = require('./app-base').AppBase;


    //ctor
    var App = function() {
        AppBase.apply(this, arguments);
    };

    App.prototype = Object.create(AppBase.prototype);
    App.prototype.constructor = App;

    __extends(App, AppBase);


    App.typeDefinition = App.mergeTypeDefinition({
        discriminator: function*(obj, typesService) {
            var def = yield* typesService.getTypeDefinition(obj.type);
            if (def.ctor !== App)
                throw new Error("App type definitions must have ctor set to App");
            return def;
        }
    }, AppBase.typeDefinition);



    App.prototype.save = function*(context) {
        context = this.getContext(context);

        //if stub is a reserved name, change it
        if (!stub)
            throw new Error("Missing stub");

        var conf = services.get('configuration');
        if (conf.reservedNames.indexOf(this.stub) > -1)
            throw new Error("Stub cannot be " + stub + ", it is reserved");

        var regex = /[a-z][a-z0-9|-]*/;
        if (!regex.test(this.stub))
            throw new Error("Stub is invalid");

        _ = yield* AppBase.prototype.save.call(this, context);
    };

    exports.App = App;

})();
