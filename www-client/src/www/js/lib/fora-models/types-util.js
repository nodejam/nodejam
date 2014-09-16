(function() {
    "use strict";
    
    var _;

    var utils = require('./utils');

    var TypesUtil = function() {
    };

    TypesUtil.prototype.isPrimitiveType = function(type) {
        return ['string', 'number', 'integer', 'boolean', 'array'].indexOf(type) > -1;
    };

    TypesUtil.prototype.isCustomType = function(type) {
        return !this.isPrimitiveType(type);
    };

    module.exports = TypesUtil;

}).call(this);
