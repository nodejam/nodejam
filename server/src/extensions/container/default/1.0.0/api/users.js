(function() {
    "use strict";

    var _;

    var models = require('fora-app-models'),
        services = require('fora-app-services'),
        FileService = require('fora-app-file-service'),
        Parser = require('fora-request-parser');

    var conf = services.get("configuration");
    var fileService = new FileService(conf);


    var create = function*() {
        var user = yield* models.User.createViaRequest(this);
        this.body = user.summarize();
    };


    var login = function*() {
        var parser = new Parser(this, services.get('typesService'));
        _ = yield* this.session.upgrade(yield* parser.body('username'));
        var session = yield* this.session.save();

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
            this.body = user.summarize();
    };


    var auth = require('fora-app-auth-service');
    module.exports = {
        create: auth({ session: 'credential' }, create),
        login: auth({ session: 'credential' }, login),
        item: auth(item)
    };

})();
