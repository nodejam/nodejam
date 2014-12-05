(function() {
    "use strict";

    var _;

    var appCommon = require('./app-common'),
        dataUtils = require('fora-data-utils'),
        DbConnector = require('fora-lib-db-connector'),
        services = require('fora-lib-services');

    var conf = services.getConfiguration();

    var App = function(params) {
        dataUtils.extend(this, params);
        if (!this.stats) {
            this.stats = new models.AppStats({
                records: 0,
                members: 0,
                lastRecord: 0
            });
        }
        if (this.my_init)
            this.my_init();
    };
    appCommon.extendApp(App);

    exports.App = App;

})();
