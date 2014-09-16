(function() {
    "use strict";

    var _;

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };


    var RecordBase = require('./record-base').RecordBase;

    //ctor
    var Record = function() {
        this.meta = this.meta || [];
        this.tags = this.tags || [];
        RecordBase.apply(this, arguments);
    };

    Record.prototype = Object.create(RecordBase.prototype);
    Record.prototype.constructor = Record;

    __extends(Record, RecordBase);

    exports.Record = Record;

})();
