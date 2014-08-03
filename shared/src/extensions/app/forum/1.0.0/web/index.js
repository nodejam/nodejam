(function() {
    "use strict";

    /* Routing */
    var members = require('./members');
    var records = require('./records');

    exports.init = function*() {
        #home
        app.use route.get '/', m_home.index

        #login
        app.use route.get '/login', m_home.login
        app.use route.get '/auth/twitter', m_auth.twitter
        app.use route.get '/auth/twitter/callback', m_auth.twitterCallback
        app.use route.get '/users/login', m_users.login

        #users
        app.use route.get '/~:username', m_users.item

        #apps
        app.use route.get '/apps', m_apps.index
        app.use route.get '/apps/new', m_apps.create
        app.use route.get '/:app', m_apps.page
        app.use route.get '/:app/:page', m_apps.page
    };

})();
