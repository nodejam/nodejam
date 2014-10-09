(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var models = require('./'),
        AppBase = require('./app-base').AppBase;

    var services = require('fora-app-services');

    //ctor
    var App = function() {
        AppBase.apply(this, arguments);
    };

    App.prototype = Object.create(AppBase.prototype);
    App.prototype.constructor = App;

    __extends(App, AppBase);


    App.prototype.save = function*() {
        var conf = services.get('configuration');

        //if stub is a reserved name, change it
        if (!this.stub)
            throw new Error("Missing stub");

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

        return yield* AppBase.prototype.save.call(this);
    };



    /*
        Records
    */
    App.prototype.createRecord = function*(params) {
        var record = yield* models.Record.create(params);
        record.appId = this.getRowId();
        return record;
    };



    App.prototype.addRecord = function*(record) {
        record.appId = this.getRowId();
        return yield* record.save();
    };



    App.prototype.getRecord = function*(stub) {
        return yield* models.Record.findOne({ 'appId': this.getRowId(), stub: stub });
    };



    App.prototype.findRecord = function*(query) {
        query.appId = this.getRowId();
        return yield* models.Record.findOne(query);
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
        query.appId = this.getRowId();
        settings = settings ? { sort: settings.sort, limit: getLimit(settings.limit, 100, 1000) } : {};
        return yield* models.Record.find(query, settings);
    };



    /*
        Membership and Permissions
    */
    App.prototype.join = function*(user) {
        if (this.access === 'public') {
            return yield* this.addRole(user, 'member');
        } else {
            throw new Error("Access denied");
        }
    };



    App.prototype.addRole = function*(user, role) {
        var membership = yield* models.Membership.findOne({ 'appId': this.getRowId(), 'user.username': user.username });

        var typesService = services.get('typesService');
        if (!membership) {
            membership = yield* typesService.constructModel(
                {
                    appId: this.getRowId(),
                    userId: user.id,
                    user: user,
                    roles: [role]
                },
                models.Membership
            );
        } else {
            if (membership.roles.indexOf(role) === -1) {
                membership.roles.push(role);
            }
        }

        return yield* membership.save();
    };



    App.prototype.removeRole = function*(user, role) {
        var membership = yield* models.Membership.findOne({ 'appId': this.getRowId(), 'user.username': user.username });
        membership.roles = membership.roles.filter(function(r) { return r != role; });
        return membership.roles.length ? (yield* membership.save()) : (yield* membership.destroy());
    };



    App.prototype.getMembership = function*(username) {
        return yield* models.Membership.findOne({ 'app.id': this.getRowId(), 'user.username': username });
    };



    App.prototype.getMemberships = function*(roles) {
        return yield* models.Membership.find(
            { 'appId': this.getRowId(), roles: { $in: roles } },
            { sort: { id: -1 }, limit: 200}
        );
    };


    exports.App = App;

})();
