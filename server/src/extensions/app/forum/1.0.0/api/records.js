(function() {
    "use strict";

    var _;

    var services = require("fora-app-services"),
        Parser = require('fora-request-parser');


    var create = function*() {
        this.body = yield* this.app.my_createRecord(this);
    };


    var edit = function*(stub) {
        this.body = yield* this.app.my_editRecord(stub, this);
    };


    var remove = function*(stub) {
        this.body = yield* this.app.my_removeRecord(stub, this);
    };


    var addMeta = function*(stub) {
        this.body = yield* this.app.my_addRecordMeta(stub, this);
    };



    var auth = require('fora-app-auth-service');
    module.exports = {
        create: auth({ session: 'user' }, create),
        edit: auth({ session: 'user' }, edit),
        remove: auth({ session: 'user' }, remove),
        addMeta: auth({ session: 'admin' }, addMeta
        )
    };


})();
