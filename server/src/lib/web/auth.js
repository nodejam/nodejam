(function() {
    "use strict";

    module.exports = function(models, db, conf) {
        var handler = function() {

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
                var token = this.query.token || this.cookies.get('token');

                if (token)
                    this.session = yield* models.Session.get({ token: token }, {}, db);

                switch (options.session) {
                    case "admin":
                        if (!this.session || !this.session.user)
                            throw new Error('No session');
                        else if (conf.admins.filter(function(u) { return u === this.session.user.username; }).length === 0)
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

        return { handler: handler };
    };
})();
