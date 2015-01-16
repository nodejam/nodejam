(function() {
    "use strict";

    var models = require('./'),
        dataUtils = require('fora-data-utils'),
        userCommon = require('./user-common'),
        DbConnector = require('fora-lib-db-connector'),
        services = require('fora-lib-services'),
        FileService = require('fora-lib-file-service'),
        Parser = require('ceramic-dictionary-parser');

    var conf = services.getConfiguration();
    var fileService = new FileService(conf);

    var User = function(params) {
        dataUtils.extend(this, params);
    };

    userCommon.extendUser(User);

    var userStore = new DbConnector(User);


    User.createViaRequest = function*(request) {
        var schemaManager = services.getSchemaManager();
        var parser = new Parser(request, request.getFormField, schemaManager);

        var user = new User({
            username: yield* parser.getField('username'),
            credentialId: request.session.credentialId,
            name: yield* parser.getField('name'),
            location: yield* parser.getField('location'),
            email: (yield* parser.getField('email') || 'unknownthis.foraproject.org'),
            about: yield* parser.getField('about'),
            lastLogin: Date.now()
        });

        yield* user.save();

        //Move images to assets
        var picture = {
            src: yield* parser.getField('picture_src'),
            small: yield* parser.getField('picture_small')
        };

        var copy = function*(sourcePath, destFilename) {
            var srcPathArr = sourcePath.split('/');
            var file = srcPathArr.pop();
            var subdir = srcPathArr.pop();
            var source = fileService.getFilePath('images', subdir, file);
            var dest = fileService.getFilePath('assets', user.assets, destFilename);
            yield* fileService.copyFile(source, dest);
        };

        yield* copy(picture.src, user.username + ".jpg");
        yield* copy(picture.small, user.username + "_t.jpg");

        return user;
    };


    User.prototype.save = function*() {
        if (!DbConnector.getRowId(this)) {
            var existing = yield* userStore.findOne({ username: this.username });
            if (!existing) {
                var conf = services.getConfiguration();
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
