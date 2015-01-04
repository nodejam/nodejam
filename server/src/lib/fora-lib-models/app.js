(function() {
    "use strict";

    var models = require('./'),
        appCommon = require('./app-common'),
        dataUtils = require('fora-data-utils'),
        DbConnector = require('fora-lib-db-connector'),
        services = require('fora-lib-services'),
        Parser = require('fora-request-parser');

    var conf = services.getConfiguration();

    var App = function(params) {
        dataUtils.extend(this, params);
        if (!this.stats) {
            this.stats = new models.AppStats({
                records: 0,
                members: 0,
                lastRecord: 0
            });
        }
        if (this.my_init)
            this.my_init();
    };
    appCommon.extendApp(App);

    var appStore = new DbConnector(App);


    App.createViaRequest = function*(request) {
        var typesService = services.getTypesService();
        var parser = new Parser(request, typesService);

        var stub = (yield* parser.body('name')).toLowerCase().trim();
        if (conf.reservedNames.indexOf(stub) > -1)
            stub = stub + "-app";
        stub = stub.replace(/\s+/g,'-').replace(/[^a-z0-9|-]/g, '').replace(/^\d*/,'');

        var app = yield* appStore.findOne({ $or: [{ stub: stub }, { name: yield* parser.body('name') }] });

        if (!app) {
            var type = yield* parser.body('type');
            var typeDefinition = yield* typesService.getTypeDefinition(type);
            var params = {
                type: type,
                name: yield* parser.body('name'),
                access: yield* parser.body('access'),
                stub: stub,
                createdBy: request.session.user,
            };
            app = yield* typesService.constructModel(params, typeDefinition);

            yield* parser.map(
                app,
                (yield* appStore.getTypeDefinition()),
                ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']
            );

            yield* app.save();
            yield* app.createRole(request.session.user, 'admin');
            return app;
        } else {
            throw new Error("App exists");
        }
    };


    App.prototype.editViaRequest = function*(request) {
        var parser = new Parser(request, services.getTypesService());

        if (request.session.user.username === request.createdBy.username || request.session.admin) {
            yield* parser.map(request, ['description', 'cover_image_src', 'cover_image_small', 'cover_image_alt', 'cover_image_credits']);
            return yield* this.save();
        } else {
            throw new Error("Access denied");
        }
    };



    App.prototype.createRecordViaRequest = function*(request) {
        var record = yield* models.Record.createViaRequest(this, request);
        this.stats.lastRecord = Date.now();
        yield* this.save();
        return record;
    };



    App.prototype.updateRecordViaRequest = function*(stub, request) {
        var record = yield* this.getRecord({ stub: stub });

        if (record) {
            if (record.createdBy.username === request.session.user.username) {
                yield* record.updateViaRequest(request);
                return record;
            } else {
                throw new Error("Access denied");
            }
        } else {
            throw new Error("Not found");
        }
    };


    App.prototype.deleteRecordViaRequest = function*(stub, request) {
        var record = yield* this.getRecord(stub);
        if (record) {
            if(record.createdBy.username === request.session.user.username) {
                yield* record.destroy();
                return record;
            } else {
                throw new Error('Access denied');
            }
        } else {
            throw new Error("Not found");
        }
    };



    App.prototype.addRecordMetaViaRequest = function*(stub, request) {
        var record = yield* this.getRecord(stub);
        if (record) {
            yield* record.addMetaViaRequest(request);
            return record;
        } else {
            throw new Error("Not found");
        }
    };



    App.prototype.deleteRecordMetaViaRequest = function*(stub, request) {
        var record = yield* this.getRecord(stub);
        if (record) {
            yield* record.deleteMetaViaRequest(request);
            return record;
        } else {
            throw new Error("Not found");
        }
    };



    App.prototype.save = function*() {
        var conf = services.getConfiguration();

        if (conf.reservedNames.indexOf(this.stub) > -1)
            throw new Error("Stub cannot be " + this.stub + ", it is reserved");

        var regex = /[a-z][a-z0-9|-]*/;
        if (!regex.test(this.stub))
            throw new Error("Stub is invalid");

        var typeParts = this.type.split('/');
        this.appType = typeParts[1];
        this.version = typeParts[2];
        var versionParts = this.version.split('.');
        this.versionMajor = parseInt(versionParts[0]);
        this.versionMinor = parseInt(versionParts[1]);
        this.versionRevision = parseInt(versionParts[2]);

        yield* appStore.save(this);
    };



    App.prototype.getRecord = function*(stub) {
        var recordStore = new DbConnector(models.Record);
        return yield* recordStore.findOne({ 'appId': DbConnector.getRowId(this), stub: stub });
    };



    App.prototype.findRecord = function*(query) {
        query.appId = DbConnector.getRowId(this);
        var recordStore = new DbConnector(models.Record);
        return yield* recordStore.findOne(query);
    };


    var getLimit = function(limit, _default, max) {
        var result = _default;
        if (limit) {
            result = limit;
            if (result > max)
                result = max;
        }
        return result;
    };


    App.prototype.findRecords = function*(query, settings) {
        query.appId = DbConnector.getRowId(this);
        settings = settings ? { sort: settings.sort, limit: getLimit(settings.limit, 100, 1000) } : {};
        var recordStore = new DbConnector(models.Record);
        return yield* recordStore.find(query, settings);
    };



    App.prototype.join = function*(user) {
        if (this.access === 'public') {
            return yield* this.createRole(user, 'member');
        } else {
            throw new Error("Access denied");
        }
    };



    App.prototype.createRole = function*(user, role) {
        var membershipStore = new DbConnector(models.Membership);
        var membership = yield* membershipStore.findOne({ 'appId': DbConnector.getRowId(this), 'user.username': user.username });

        var typesService = services.getTypesService();
        if (!membership) {
            membership = new models.Membership(
                {
                    appId: DbConnector.getRowId(this),
                    userId: user.id,
                    user: user,
                    roles: [role]
                }
            );
        } else {
            if (membership.roles.indexOf(role) === -1) {
                membership.roles.push(role);
            }
        }

        yield* membership.save();
        return membership;
    };



    App.prototype.deleteRole = function*(user, role) {
        var membershipStore = new DbConnector(models.Membership);
        var membership = yield* membershipStore.findOne({ 'appId': this.getRowId(), 'user.username': user.username });
        membership.roles = membership.roles.filter(function(r) { return r != role; });
        if (membership.roles.length)
            yield* membership.save();
        else
            yield* membership.destroy();
        return membership;
    };



    App.prototype.getMembership = function*(username) {
        var membershipStore = new DbConnector(models.Membership);
        return yield* membershipStore.findOne({ 'app.id': this.getRowId(), 'user.username': username });
    };



    App.prototype.getMemberships = function*(roles) {
        var membershipStore = new DbConnector(models.Membership);
        return yield* membershipStore.find(
            { 'appId': this.getRowId(), roles: { $in: roles } },
            { sort: { id: -1 }, limit: 200}
        );
    };

    exports.App = App;

})();
