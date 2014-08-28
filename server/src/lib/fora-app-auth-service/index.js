(function() {
    "use strict";

    var models = require("fora-app-models"),
        services = require("fora-app-services");


    module.exports = function() {
        var conf = services.get('configuration'),
            typesService = services.get('typesServices'),
            db = services.get('db');

        var options, fn;

        if (arguments.length === 1) {
            options = {};
            fn = arguments[0];
        }
        else {
            options = arguments [0];
            fn = arguments[1];
        }

        return function*() {
            var self = this;

            if (!this.session) {
                var token = this.query.token || this.cookies.get('token');

                if (token)
                    this.session = yield* models.Session.findOne({ token: token }, { typesService: typesService, db: db });
            }

            switch (options.session) {
                case "admin":
                    if (!this.session || !this.session.user)
                        throw new Error('No session');
                    else if (conf.admins.filter(function(u) { return u === self.session.user.username; }).length === 0)
                        throw new Error('Not admin');

                    this.session.admin = true;
                    break;

                case 'credential':
                case 'any':
                    if (!this.session) {
                        throw new Error('No session');
                    }
                    break;

                case 'user':
                    if (!this.session || !this.session.user)
                        throw new Error('No session');
                    break;
            }

            return yield* fn.apply(this, arguments);
        };
    };
})();
