(function() {
    "use strict";

    var ForaUI = require('fora-ui');

    var index = function*() {
        var records = yield* this.app.getRecords(12, { "_id": -1 });

        yield* ForaUI.renderers.simple.app({
            records: records,
            appTemplate: 'index',
            recordTemplate: 'list'
        }, this);
    }


    var record = function*(stub) {
        record = yield* this.app.getRecord(stub);

        yield* ForaUI.renderers.simple.record({
            record: record,
            appTemplate: 'item',
            recordTemplate: 'item'
        }, this);
    }


    var about = function*() {

    }

    exports.init = function*() {
        this.routes.pages.add("", index);
        this.routes.pages.add("about", about);
        this.routes.pages.add(":record", record);
    }
})();
