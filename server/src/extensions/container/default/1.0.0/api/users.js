(function() {
    "use strict";

    var _;

    var models = require('fora-lib-models'),
        services = require('fora-lib-services'),
        FileService = require('fora-lib-file-service'),
        Parser = require('fora-request-parser');

    var conf = services.getConfiguration();
    var fileService = new FileService(conf);


    var create = function*() {
        var user = yield* models.User.createViaRequest(this);
        this.body = user.summarize();
    };


    var login = function*() {
        var parser = new Parser(this, services.getTypesService());
        yield* this.session.upgrade(yield* parser.body('username'));
        yield* this.session.save();

        var user = this.session.user;
        user.token = this.session.token;

        this.cookies.set("userId", user.id.toString(), { httpOnly: false });
        this.cookies.set("username", user.username, { httpOnly: false });
        this.cookies.set("fullName", user.name, { httpOnly: false });
        this.cookies.set("token", this.session.token);

        this.body = user;
    };


    var item = function*(username) {
        var user = yield* models.User.findOne({ username: username });
        if (user)
            this.body = user.summarize();
    };


    var auth = require('fora-lib-auth-service');
    module.exports = {
        create: auth({ session: 'credential' }, create),
        login: auth({ session: 'credential' }, login),
        item: auth(item)
    };

})();
