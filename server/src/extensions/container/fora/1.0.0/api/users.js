(function() {
    "use strict";

    var create = function*() {

        var user = new models.User({
            username: yield* this.parser.body('username'),
            credentialId: this.session.credentialId,
            name: yield* this.parser.body('name'),
            location: yield* this.parser.body('location'),
            email: (yield* this.parser.body('email') || 'unknownthis.foraproject.org'),
            about: yield* this.parser.body('about'),
            lastLogin: Date.now()
        });

        user = yield* user.save({}, db);

        //Move images to assets
        var picture = {
            src: yield* this.parser.body('picture_src'),
            small: yield* this.parser.body('picture_small')
        };

        var copy = function*(sourcePath, destFilename) {
            var srcPathArr = sourcePath.split('/');
            var file = srcPathArr.pop();
            var subdir = srcPathArr.pop();
            var source = fsutils.getFilePath('images', subdir, file);
            var dest = fsutils.getFilePath('assets', user.assets, destFilename);
            _ = yield* fsutils.copyFile(source, dest);
        };

        _ = yield* copy(picture.src, user.username + ".jpg");
        _ = yield* copy(picture.small, user.username + "_t.jpg");

        this.body = user.summarize({}, db);
    };


    var login = function*() {
        var session = yield* this.session.upgrade(yield* this.parser.body('username'));

        var user = session.user;
        user.token = session.token;

        this.cookies.set("userId", user.id.toString(), { httpOnly: false });
        this.cookies.set("username", user.username, { httpOnly: false });
        this.cookies.set("fullName", user.name, { httpOnly: false });
        this.cookies.set("token", session.token);

        this.body = user;
    };


    var item = function*(username) {
        var user = yield* models.User.get({ username: username }, {}, db);
        if (user)
            this.body = user.summarize({}, db);
    };

    module.exports = {
        create: auth.handler({ session: 'credential' }, create),
        login: auth.handler({ session: 'credential' }, login),
        item: auth.handler(item)
    };

})();
