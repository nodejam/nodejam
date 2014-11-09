(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        FileService = require('fora-app-file-service'),
        conf = require('../../../../../config');

    var Parser = require('fora-request-parser');
    var fileService = new FileService(conf);

    var create = function*() {
        var typesService = services.get('typesService');
        var parser = new Parser(this, typesService);

        var user = new models.User(
            {
                username: yield* parser.body('username'),
                credentialId: this.session.credentialId,
                name: yield* parser.body('name'),
                location: yield* parser.body('location'),
                email: (yield* parser.body('email') || 'unknownthis.foraproject.org'),
                about: yield* parser.body('about'),
                lastLogin: Date.now()
            }
        );
        user = yield* user.save();

        //Move images to assets
        var picture = {
            src: yield* parser.body('picture_src'),
            small: yield* parser.body('picture_small')
        };

        var copy = function*(sourcePath, destFilename) {
            var srcPathArr = sourcePath.split('/');
            var file = srcPathArr.pop();
            var subdir = srcPathArr.pop();
            var source = fileService.getFilePath('images', subdir, file);
            var dest = fileService.getFilePath('assets', user.assets, destFilename);
            _ = yield* fileService.copyFile(source, dest);
        };

        _ = yield* copy(picture.src, user.username + ".jpg");
        _ = yield* copy(picture.small, user.username + "_t.jpg");

        this.body = yield* user.summarize();
    };


    var login = function*() {
        var parser = new Parser(this, services.get('typesService'));
        var session = yield* this.session.upgrade(yield* parser.body('username'));

        var user = session.user;
        user.token = session.token;

        this.cookies.set("userId", user.id.toString(), { httpOnly: false });
        this.cookies.set("username", user.username, { httpOnly: false });
        this.cookies.set("fullName", user.name, { httpOnly: false });
        this.cookies.set("token", session.token);

        this.body = user;
    };


    var item = function*(username) {
        var user = yield* models.User.findOne({ username: username });
        if (user)
            this.body = yield* user.summarize();
    };


    var auth = require('fora-app-auth-service');
    module.exports = {
        create: auth({ session: 'credential' }, create),
        login: auth({ session: 'credential' }, login),
        item: auth(item)
    };

})();
