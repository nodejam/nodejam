// Generated by CoffeeScript 1.6.2
(function() {
  var AppError, BaseModel, Forum, User,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  AppError = require('../common/apperror').AppError;

  BaseModel = require('./basemodel').BaseModel;

  User = require('./user').User;

  Forum = (function(_super) {
    __extends(Forum, _super);

    Forum._meta = {
      type: Forum,
      forum: 'forums',
      fields: {
        network: 'string',
        name: 'string',
        stub: 'stub',
        settings: 'object',
        icon: 'string',
        iconThumbnail: 'string',
        cover: {
          type: 'string',
          required: 'false'
        },
        createdBy: {
          type: User.Summary,
          validate: function() {
            return this.createdBy.validate();
          }
        },
        moderators: {
          type: User.Summary,
          validate: function() {
            var m, _i, _len, _ref, _results;

            if (this.moderators.length) {
              _ref = this.moderators;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                m = _ref[_i];
                _results.push(m.validate());
              }
              return _results;
            } else {
              return 'There should be at least one moderator.';
            }
          }
        },
        totalItems: 'number',
        totalSubscribers: 'number',
        createdAt: {
          autoGenerated: true,
          event: 'created'
        },
        updatedAt: {
          autoGenerated: true,
          event: 'updated'
        }
      },
      logging: {
        isLogged: true,
        onInsert: 'NEW_FORUM'
      }
    };

    function Forum(params) {
      this.summarize = __bind(this.summarize, this);
      this.save = __bind(this.save, this);
      var _ref, _ref1;

      if ((_ref = this.totalItems) == null) {
        this.totalItems = 0;
      }
      if ((_ref1 = this.totalSubscribers) == null) {
        this.totalSubscribers = 0;
      }
      this.settings = {};
      this.moderators = [];
      Forum.__super__.constructor.apply(this, arguments);
    }

    Forum.prototype.save = function(context, cb) {
      return Forum.__super__.save.apply(this, arguments);
    };

    Forum.prototype.summarize = function(fields) {
      var result;

      if (fields == null) {
        fields = [];
      }
      fields = fields.concat(['name', 'stub', 'type', 'createdBy', 'network']);
      result = Forum.__super__.summarize.call(this, fields);
      result.id = this._id.toString();
      return result;
    };

    Forum.validateSummary = function(forum) {
      var errors, field, required, _errors, _i, _len;

      errors = [];
      if (!forum) {
        errors.push("Invalid forum.");
      }
      required = ['id', 'name', 'stub', 'type', 'createdBy', 'network'];
      for (_i = 0, _len = required.length; _i < _len; _i++) {
        field = required[_i];
        if (!forum[field]) {
          errors.push("Invalid " + field);
        }
      }
      _errors = Forum._models.User.validateSummary(forum.createdBy);
      if (_errors.length) {
        errors.push('Invalid createdBy.');
        errors = errors.concat(_errors);
      }
      return errors;
    };

    return Forum;

  }).call(this, BaseModel);

  exports.Forum = Forum;

}).call(this);
