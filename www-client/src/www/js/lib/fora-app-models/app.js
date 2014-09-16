(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var models = require('./'),
        AppBase = require('./app-base').AppBase,
        typeHelpers = require('fora-app-type-helpers');

    //ctor
    var App = function() {
        AppBase.apply(this, arguments);
    };

    App.prototype = Object.create(AppBase.prototype);
    App.prototype.constructor = App;

    __extends(App, AppBase);

    exports.App = App;

})();
