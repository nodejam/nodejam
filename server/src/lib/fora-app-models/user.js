(function() {
    "use strict";

    var _;

    var models = require('./'),
        dataUtils = require('fora-data-utils'),
        userCommon = require('./user-common'),
        DbConnector = require('fora-app-db-connector'),
        services = require('fora-app-services');


    var User = function(params) {
        dataUtils.extend(this, params);
    };
    userCommon.extendUser(User);

    var userStore = new DbConnector(User);

    User.prototype.save = function*() {
        if (!DbConnector.getRowId(this)) {
            var existing = yield* userStore.findOne({ username: this.username });
            if (!existing) {
                var conf = services.get('configuration');
                this.assets = (dataUtils.getHashCode(this.username) % conf.services.file.userDirCount).toString();
                this.lastLogin = 0;
                this.followingCount = 0;
                this.followerCount = 0;
            } else {
                throw new Error("User(#{@username}) already exists");
            }
        }
        return yield* userStore.save(this);
    };


    User.prototype.getRecords = function*(limit, sort, context) {
        return yield* models.Record.find(
            { "createdBy.id": this.getRowId(), state: 'published' },
            { sort: sort, limit: limit },
            context
        );
    };

    exports.User = User;

})();
