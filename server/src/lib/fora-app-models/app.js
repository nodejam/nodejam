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


    App.prototype.save = function*(context) {
        var conf = services.get('configuration');

        //if stub is a reserved name, change it
        if (!this.stub)
            throw new Error("Missing stub");

        if (conf.reservedNames.indexOf(this.stub) > -1)
            throw new Error("Stub cannot be " + this.stub + ", it is reserved");

        var regex = /[a-z][a-z0-9|-]*/;
        if (!regex.test(this.stub))
            throw new Error("Stub is invalid");

        return yield* AppBase.prototype.save.call(this, context);
    };


    App.prototype.summarize = function(context) {
        return new models.AppSummary({
            id: context.db.getRowId(this),
            name: this.name,
            stub: this.stub,
            createdBy: this.createdBy
        });
    };


    App.prototype.getView = function*(name, context) {
        switch (name) {
            case 'card':
                return {
                id: context.db.getRowId(this),
                name: this.name,
                description: this.description,
                stub: this.stub,
                createdBy: this.createdBy,
                cache: this.cache,
                image: this.cover ? this.cover.image ? this.cover.image.small : void 0 : void 0
            };
        }
    };


    App.prototype.join = function*(user, context) {
        if (this.access === 'public') {
            return yield* this.addRole(user, 'member', context);
        } else {
            throw new Error("Access denied");
        }
    };


    App.prototype.addRecord = function*(record, context) {
        record.appId = context.db.getRowId(this);
        record.app = this.summarize(context);
        return yield* record.save(context);
    };


    App.prototype.getRecord = function*(stub, context) {
        return yield* models.Record.find({ 'appId': context.db.getRowId(this), stub: stub }, context);
    };


    App.prototype.getRecords = function*(limit, sort, context) {
        return yield* models.Record.find({ 'appId': context.db.getRowId(this), state: 'published' }, { sort: sort, limit: limit }, context);
    };


    App.prototype.addRole = function*(user, role, context) {
        var membership = yield* models.Membership.findOne({ 'appId': context.db.getRowId(this), 'user.username': user.username }, context);

        if (!membership) {
            membership = new models.Membership({
                appId: context.db.getRowId(this),
                app: this.summarize(context),
                userId: user.id,
                user: user,
                roles: [role]
            });
        } else {
            if (membership.roles.indexOf(role) === -1) {
                membership.roles.push(role);
            }
        }

        return yield* membership.save(context);
    };


    App.prototype.removeRole = function*(user, role, context) {
        var membership = yield* models.Membership.findOne({ 'appId': context.db.getRowId(this), 'user.username': user.username }, context);
        membership.roles = membership.roles.filter(function(r) { return r != role; });
        if (membership.roles.length) {
            return yield* membership.save();
        } else {
            return yield* membership.destroy();
        }
    };


    App.prototype.getMembership = function*(username, context) {
      return yield* models.Membership.findOne({ 'app.id': context.db.getRowId(this), 'user.username': username }, context);
    };


    App.prototype.getMemberships = function*(roles, context) {
        return yield* models.Membership.find(
            { 'appId': context.db.getRowId(this), roles: { $in: roles } },
            { sort: { id: -1 }, limit: 200},
            context
        );
    };


    exports.App = App;

})();
