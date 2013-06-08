// Generated by CoffeeScript 1.6.2
(function() {
  var AppError, BaseModel, Network, conf, _ref,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  BaseModel = require('./basemodel').BaseModel;

  AppError = require('../common/apperror').AppError;

  conf = require('../conf');

  Network = (function(_super) {
    __extends(Network, _super);

    function Network() {
      this.validate = __bind(this.validate, this);      _ref = Network.__super__.constructor.apply(this, arguments);
      return _ref;
    }

    /*
        Fields
            - name
            - stub
            - authenticationTypes (list of { name:string, params:depends on name })
            - collection types (list of string)
            - admins
    */


    Network._meta = {
      type: Network,
      collection: 'networks',
      logging: {
        isLogged: true
      }
    };

    Network.prototype.validate = function() {
      var admin, errors, item, type, valid, _errors, _i, _j, _k, _len, _len1, _len2, _ref1, _ref2, _ref3;

      errors = Network.__super__.validate.call(this).errors;
      if (!this.name) {
        errors.push('Network name is missing.');
      }
      if (!this.stub) {
        errors.push('Stub is missing.');
      }
      if (!this.authenticationTypes || !this.authenticationTypes.length) {
        errors.push('Authentication Types are missing.');
      } else {
        _ref1 = this.authenticationTypes;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          type = _ref1[_i];
          if (['facebook', 'twitter', 'custom'].indexOf(type.name === -1)) {
            errors.push("" + type.name + " is not a valid Authentication Type.");
          }
          if (type.name === 'twitter') {
            if (!type.params) {
              errors.push("Twitter authentication parameters are missing.");
            } else {
              if (!type.params.TWITTER_CONSUMER_KEY) {
                errors.push("Twitter consumer key is missing.");
              }
              if (!type.params.TWITTER_SECRET) {
                errors.push("Twitter consumer secret is missing.");
              }
              if (!type.params.TWITTER_CALLBACK) {
                errors.push("Twitter callback is missing.");
              }
            }
          }
        }
      }
      if (!this.collectionTypes || !this.collectionTypes.length) {
        errors.push('Collection Types are missing.');
      } else {
        valid = (function() {
          var _j, _len1, _ref2, _results;

          _ref2 = conf.collectionTypes;
          _results = [];
          for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
            item = _ref2[_j];
            _results.push(item.name);
          }
          return _results;
        })();
        _ref2 = this.collectionTypes;
        for (_j = 0, _len1 = _ref2.length; _j < _len1; _j++) {
          type = _ref2[_j];
          if (valid.indexOf(type === -1)) {
            errors.push("" + type + " is not a valid Collection Type.");
          }
        }
      }
      if (!this.admins || !this.admins.length) {
        errors.push('Admins are missing.');
      } else {
        _ref3 = this.admins;
        for (_k = 0, _len2 = _ref3.length; _k < _len2; _k++) {
          admin = _ref3[_k];
          _errors = Collection._models.User.validateSummary(admin);
          if (_errors.length) {
            errors.push('Invalid admin.');
            errors = errors.concat(_errors);
          }
        }
      }
      return {
        isValid: errors.length === 0,
        errors: errors
      };
    };

    return Network;

  })(BaseModel);

  exports.Network = Network;

}).call(this);