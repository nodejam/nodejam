(function() {
    "use strict";

    var _;

    var services = require("fora-lib-services"),
        Parser = require('fora-request-parser');


    var create = function*() {
        this.body = yield* this.app.my_createRecord(this);
    };


    var update = function*(stub) {
        this.body = yield* this.app.my_updateRecord(stub, this);
    };


    var del = function*(stub) {
        this.body = yield* this.app.my_deleteRecord(stub, this);
    };


    var addMeta = function*(stub) {
        this.body = yield* this.app.my_addRecordMeta(stub, this);
    };



    var auth = require('fora-lib-auth-service');
    module.exports = {
        create: auth({ session: 'user' }, create),
        update: auth({ session: 'user' }, update),
        del: auth({ session: 'user' }, del),
        addMeta: auth({ session: 'admin' }, addMeta
        )
    };


})();
