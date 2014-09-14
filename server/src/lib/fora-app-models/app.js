(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var models = require('./'),
        AppBase = require('./app-base').AppBase,
        typeHelpers = require('fora-app-type-helpers');

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
        var context = services.copy();
        var record = yield* models.Record.create(params);
        record.appId = context.db.getRowId(this);
        return record;
    };



    App.prototype.addRecord = function*(record) {
        var context = services.copy();
        record.appId = context.db.getRowId(this);
        return yield* record.save(context);
    };



    App.prototype.getRecord = function*(stub) {
        var context = services.copy();
        return yield* models.Record.findOne({ 'appId': context.db.getRowId(this), stub: stub }, context);
    };



    App.prototype.findRecord = function*(query) {
        var context = services.copy();
        query.appId = context.db.getRowId(this);
        return yield* models.Record.findOne(query, context);
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
        var context = services.copy();
        query.appId = context.db.getRowId(this);
        settings = settings ? { sort: settings.sort, limit: getLimit(settings.limit, 100, 1000) } : {};
        return yield* models.Record.find(query, settings, context);
    };



    /*
        Membership and Permissions
    */
    App.prototype.join = function*(user) {
        if (this.access === 'public') {
            return yield* this.addRole(user, 'member', services.copy());
        } else {
            throw new Error("Access denied");
        }
    };



    App.prototype.addRole = function*(user, role) {
        var context = services.copy();
        var membership = yield* models.Membership.findOne({ 'appId': context.db.getRowId(this), 'user.username': user.username }, context);

        if (!membership) {
            membership = new models.Membership({
                appId: context.db.getRowId(this),
                userId: user.id,
                user: user,
                roles: [role]
            });
        } else {
            if (membership.roles.indexOf(role) === -1) {
                membership.roles.push(role);
            }
        }

        return yield* membership.save();
    };



    App.prototype.removeRole = function*(user, role) {
        var context = services.copy();
        var membership = yield* models.Membership.findOne({ 'appId': context.db.getRowId(this), 'user.username': user.username }, services.copy());
        membership.roles = membership.roles.filter(function(r) { return r != role; });
        if (membership.roles.length) {
            return yield* membership.save();
        } else {
            return yield* membership.destroy();
        }
    };



    App.prototype.getMembership = function*(username) {
        var context = services.copy();
        return yield* models.Membership.findOne({ 'app.id': context.db.getRowId(this), 'user.username': username }, context);
    };



    App.prototype.getMemberships = function*(roles) {
        var context = services.copy();
        return yield* models.Membership.find(
            { 'appId': context.db.getRowId(this), roles: { $in: roles } },
            { sort: { id: -1 }, limit: 200},
            context
        );
    };


    /*
        Summarize
    */
    App.prototype.summarize = function() {
        return new models.AppSummary({
            id: services.get('db').getRowId(this),
            name: this.name,
            stub: this.stub,
            createdBy: this.createdBy
        });
    };

    exports.App = App;

})();
