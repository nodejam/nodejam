// Generated by CoffeeScript 1.6.3
(function() {
  var clone, deepCloneObject, extend, getHashCode, __Clone;

  __Clone = function() {};

  clone = function(obj) {
    __Clone.prototype = obj;
    return new __Clone;
  };

  deepCloneObject = function(obj) {
    var key, temp, value;
    if ((obj === null) || (typeof obj !== 'object')) {
      return obj;
    } else {
      temp = {};
      for (key in obj) {
        value = obj[key];
        temp[key] = deepCloneObject(value);
      }
      return temp;
    }
  };

  extend = function(target, source, fnCanCopy) {
    var key, val;
    for (key in source) {
      val = source[key];
      if ((!target.hasOwnProperty(key)) && ((!fnCanCopy) || fnCanCopy(key))) {
        target[key] = val;
      }
    }
    return target;
  };

  getHashCode = function(str) {
    var char, hash, i, _i, _ref;
    hash = 0;
    if (str.length !== 0) {
      for (i = _i = 0, _ref = str.length; _i < _ref; i = _i += 1) {
        char = str.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash;
      }
    }
    return Math.abs(hash);
  };

  module.exports = {
    clone: clone,
    deepCloneObject: deepCloneObject,
    extend: extend,
    getHashCode: getHashCode
  };

}).call(this);
