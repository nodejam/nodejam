(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var models = require('./'),
        typeHelpers = require('fora-type-helpers'),
        UserBase = require('./user-base').UserBase;


    var User = function() {
        UserBase.apply(this, arguments);
    };

    User.prototype = Object.create(UserBase.prototype);
    User.prototype.constructor = User;

    __extends(User, UserBase);


    User.prototype.save = function*(context) {
        if (!context.db.getRowId(this)) {
            var existing = yield* User.get({ username: this.username }, context);
            if (!existing) {
                conf = services.get('configurationService');
                this.assets = (typeHelpers.getHashCode(this.username) % conf.userDirCount).toString();
                this.lastLogin = 0;
                this.followingCount = 0;
                this.followerCount = 0;
                _ = yield* ForaDbModel.prototype.save.apply(this, arguments);
            } else {
                throw new Error("User(#{@username}) already exists");
            }
        } else {
            return yield* ForaDbModel.prototype.save.apply(this, arguments);
        }
    };


    User.prototype.save = function*(limit, sort, context) {
        return yield* models.Record.find(
            { createdById: context.db.getRowId(this), state: 'published' },
            function(cursor) {
                return cursor.sort(sort).limit(limit);
            },
            context
        );
    };

    exports.User = User;

})();
