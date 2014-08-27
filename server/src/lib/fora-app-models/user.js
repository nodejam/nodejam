(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var models = require('./'),
        typeHelpers = require('fora-app-type-helpers'),
        UserBase = require('./user-base').UserBase;

    var services = require('fora-app-services');

    var User = function() {
        UserBase.apply(this, arguments);
    };

    User.prototype = Object.create(UserBase.prototype);
    User.prototype.constructor = User;

    __extends(User, UserBase);


    User.prototype.save = function*(context) {
        if (!context.db.getRowId(this)) {
            var existing = yield* User.findOne({ username: this.username }, context);
            if (!existing) {
                var conf = services.get('configuration');
                this.assets = (typeHelpers.getHashCode(this.username) % conf.services.file.userDirCount).toString();
                this.lastLogin = 0;
                this.followingCount = 0;
                this.followerCount = 0;
                return yield* UserBase.prototype.save.apply(this, arguments);
            } else {
                throw new Error("User(#{@username}) already exists");
            }
        } else {
            return yield* UserBase.prototype.save.apply(this, arguments);
        }
    };


    User.prototype.getRecords = function*(limit, sort, context) {
        return yield* models.Record.find(
            { createdById: context.db.getRowId(this), state: 'published' },
            { sort: sort, limit: limit },
            context
        );
    };

    exports.User = User;

})();
