(function() {

    var odm = require('fora-models');

    var ForaModel = function() {
        odm.BaseModel.apply(this, arguments);
    };

    ForaModel.prototype = Object.create(odm.BaseModel.prototype);
    ForaModel.prototype.constructor = ForaModel;


    var ForaDbModel = function() {
        odm.DatabaseModel.apply(this, arguments);
    };

    ForaDbModel.prototype = Object.create(odm.DatabaseModel.prototype);
    ForaDbModel.prototype.constructor = ForaDbModel;

    exports.ForaModel = ForaModel;
    exports.ForaDbModel = ForaDbModel;

})();
