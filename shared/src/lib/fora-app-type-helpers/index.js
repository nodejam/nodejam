(function() {
    "use strict";

    //neat trick via http://oranlooney.com/functional-javascript
    var __Clone = function() {};
    var clone = function(obj) {
        __Clone.prototype = obj;
        return new __Clone();
    };


    var deepCloneObject = function(obj) {
        if ((obj === undefined) || (obj === null) || (typeof(obj) !== 'object')) {
            return obj;
        } else {
            var temp = {};
            for (var key in obj) {
                var value = obj[key];
                temp[key] = deepCloneObject(value);
            }
            return temp;
        }
    };


    var extend = function(target, source, fnCanCopy) {
        for (var key in source) {
            var val = source[key];
            if (!target.hasOwnProperty(key) && (!fnCanCopy || fnCanCopy(key))) {
                target[key] = val;
            }
        }
        return target;
    };


    var getHashCode = function(str) {
        var hash = 0;
        if (str.length !== 0) {
            for (var i = 0; i < str.length; i++) {
                var char = str.charCodeAt(i);
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

})();
