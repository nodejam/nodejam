(function() {

    "use strict";

    var recordCommon = require('./record-common'),
        dataUtils = require('fora-lib-data-utils');

    var Record = function(params) {
        dataUtils.extend(this, params);
        this.meta = this.meta || [];
        this.tags = this.tags || [];
        if (this.my_init)
            this.my_init();
    };

    recordCommon.extendRecord(Record);

    exports.Record = Record;

})();
