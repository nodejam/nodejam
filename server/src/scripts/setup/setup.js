(function() {

    "use strict";

    var _;

    var http = require('http'),
        path = require('path'),
        fs = require('fs'),
        querystring = require('querystring'),
        co = require('co'),
        thunkify = require('fora-node-thunkify'),
        logger = require('fora-app-logger'),
        data = require('./data'),
        conf = require('../../config');

    logger.log("Setup started at " + new Date());
    logger.log("NODE_ENV is " + process.env.NODE_ENV);
    logger.log("Setup will connect to database " + conf.db.name + " on " + conf.db.host);

    var argv = require('optimist').argv;

    var HOST = argv.host || 'local.foraproject.org';
    var PORT = argv.port ? parseInt(argv.port) : 80;

    logger.log("Setup will connect to " + HOST + ":" + PORT);

    var init = function*() {
        var Database = require('fora-db');
        var database = new Database(conf.db);

        var _globals = {};
        var db, _doHttpRequest;

        var del = function*() {
            if(process.env.NODE_ENV === 'development') {
                logger.log('Deleting main database.');
                db = yield* database.deleteDatabase();
                logger.log('Everything is gone now.');
            } else {
                logger.log("Delete database can only be used if NODE_ENV is 'development'");
            }
        };

        var create = function*() {
            logger.log('This script will setup basic data. Calls the latest HTTP API.');

            //Create Users
            _globals.sessions = {};
            _doHttpRequest = thunkify(doHttpRequest);

            var user, token, resp, cred, adminkey;
            for (var _i = 0; _i < data.users.length; _i++) {
                user = data.users[_i];

                logger.log("Creating a credential for " + user.username);

                cred = {
                    secret: conf.services.auth.adminkeys.default,
                    type: user.credential_type
                };

                switch(cred.type) {
                    case 'builtin':
                        cred.username = user.credential_username;
                        cred.password = user.credential_password;
                        cred.email = user.email;
                        break;
                    case 'twitter':
                        cred.username = user.credential_username;
                        cred.id = user.credential_id;
                        cred.accessToken = user.credential_accessToken;
                        cred.accessTokenSecret = user.credential_accessTokenSecret;
                        cred.email = user.email;
                        break;
                }

                resp = yield* _doHttpRequest('/api/v1/credentials', querystring.stringify(cred), 'post');
                token = JSON.parse(resp).token;

                resp = yield* _doHttpRequest("/api/v1/users?token=" + token, querystring.stringify(user), 'post');
                resp = JSON.parse(resp);
                logger.log("Created " + resp.username);
                _globals.sessions[user.username] = resp;

                logger.log("Creating session for " + resp.username);
                resp = yield* _doHttpRequest("/api/v1/login?token=" + token, querystring.stringify({ token: token, username: user.username }), 'post');
                _globals.sessions[user.username].token = JSON.parse(resp).token;
            }

            var apps = {};

            var app;
            for (_i = 0; _i < data.apps.length; _i++) {
                app = data.apps[_i];
                token = _globals.sessions[app._createdBy].token;
                logger.log("Creating a new app " + app.name + " with token " + token);
                delete app._createdBy;

                if (app._message)
                    app.message = fs.readFileSync(path.resolve(__dirname, "apps/" + app._message), 'utf-8');
                delete app._message;

                if (app._about)
                    app.about = fs.readFileSync(path.resolve(__dirname, "apps/" + app._about), 'utf-8');
                delete app._about;

                app.type = "app/forum/1.0.0";
                resp = yield* _doHttpRequest("/api/v1/apps?token=" + token, querystring.stringify(app), 'post');
                var appJson = JSON.parse(resp);
                apps[appJson.stub] = appJson;
                logger.log("Created " + appJson.name);

                for (var u in _globals.sessions) {
                    var uToken = _globals.sessions[u];
                    if (uToken.token !== token) {
                        resp = yield* _doHttpRequest("/api/app/" + appJson.stub + "/members?token=" + uToken.token, querystring.stringify(app), 'post');
                        resp = JSON.parse(resp);
                        logger.log(u + " joined " + app.name);
                    }
                }
            }

            for (_i = 0; _i < data.records.length; _i++) {
                var article = data.records[_i];
                token = _globals.sessions[article._createdBy].token;
                adminkey = _globals.sessions.jeswin.token;

                logger.log("Creating a new article with token " + token);
                logger.log("Creating " + article.title);

                article.content_text = fs.readFileSync(path.resolve(__dirname, "records/" + article._content), 'utf-8');
                article.content_format = 'markdown';
                article.state = 'published';
                app = article._app;
                var meta = article._meta;

                delete article._app;
                delete article._createdBy;
                delete article._content;
                delete article._meta;

                resp = yield* _doHttpRequest("/api/app/" + app + "?token=" + token, querystring.stringify(article), 'post');
                resp = JSON.parse(resp);
                logger.log("Created " + resp.title + " with stub " + resp.stub);

                var metaTags = meta.split(',');
                for (var _i2 = 0; _i2 < metaTags.length; _i2++) {
                    var metaTag = metaTags[_i2];
                    resp = yield* _doHttpRequest("/api/app/" + app + "/admin/records/" + resp.stub + "?token=" + adminkey,
                        querystring.stringify({ meta: metaTag}), 'put');
                    resp = JSON.parse(resp);
                    logger.log("Added " + metaTag + " tag to article " + resp.title);
                }
            }

            //Without this return, CS will create a wrapper function to return the results (array) of: for metaTag in meta.split(',')
            return;
        };

        if (argv["delete"]) {
            _ = yield* del();
            return process.exit();
        } else if (argv.create) {
            _ = yield* create();
            return process.exit();
        } else if (argv.recreate) {
            _ = yield* del();
            _ = yield* create();
            return process.exit();
        } else {
            logger.log('Invalid option.');
            return process.exit();
        }
    };


    var doHttpRequest = function(url, data, method, cb) {
        var options, req, response;
        logger.log("HTTP " + (method.toUpperCase()) + " to " + url);
        options = {
            host: HOST,
            port: PORT,
            path: url,
            method: method,
            headers: data ? {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': data.length
                } : {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Content-Length': 0
            }
        };
        response = '';
        req = http.request(options, function(res) {
            res.setEncoding('utf8');

            res.on('data', function(chunk) {
                return response += chunk;
            });

            return res.on('end', function() {
                logger.log(response);
                return cb(null, response);
            });
        });

        if (data) {
            req.write(data);
        }
        return req.end();
    };

    (co(function*() {
      return yield* init();
    }))();

})();
