(function() {
    "use strict";

    var _;

    var Database = function(conf) {
        this.conf = conf;
        switch (this.conf.type) {
            case 'mongodb':
                this.rowId = this.conf.rowId || '_id';
        }
    };

    Database.prototype.getRowId = function(obj) {
        return obj[this.rowId] ? obj[this.rowId].toString() : null;
    };

    Database.prototype.setRowId = function(obj, val) {
        if (val) {
            obj[this.rowId] = val;
        }
        return obj;
    };

    module.exports = Database;

})();
