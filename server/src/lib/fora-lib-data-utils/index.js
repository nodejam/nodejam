(function () {

    "use strict";

    var isPrimitiveType = function(type) {
        return ['string', 'number', 'integer', 'boolean', 'array'].indexOf(type) > -1;
    };



    var isCustomType = function(type) {
        return !this.isPrimitiveType(type);
    };



    /*
        Clones an object.
    */
    var __Clone = function() {};
    var clone = function(obj) {
        __Clone.prototype = obj;
        return new __Clone();
    };



    var extend = function(target, source, fnCanCopy) {
        for (var key in source) {
            var val = source[key];
            if (!target.hasOwnProperty(key) && (!fnCanCopy || fnCanCopy(key)) && val !== undefined) {
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
        isPrimitiveType: isPrimitiveType,
        isCustomType: isCustomType,
        clone: clone,
        extend: extend,
        getHashCode: getHashCode
    };

})();
