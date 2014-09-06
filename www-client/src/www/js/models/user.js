(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var UserBase = require('./user-base').UserBase;

    var User = function() {
        UserBase.apply(this, arguments);
    };

    User.prototype = Object.create(UserBase.prototype);
    User.prototype.constructor = User;

    __extends(User, UserBase);

    exports.User = User;

})();
