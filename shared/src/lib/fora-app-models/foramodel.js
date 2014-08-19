(function() {

    var __hasProp = {}.hasOwnProperty,
        __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

    var odm = require('fora-models');

    var ForaModel = function() {
        odm.BaseModel.apply(this, arguments);
    };

    ForaModel.prototype = Object.create(odm.BaseModel.prototype);
    ForaModel.prototype.constructor = ForaModel;

    __extends(ForaModel, odm.BaseModel);


    var ForaDbModel = function() {
        odm.DatabaseModel.apply(this, arguments);
    };

    ForaDbModel.prototype = Object.create(odm.DatabaseModel.prototype);
    ForaDbModel.prototype.constructor = ForaDbModel;

    __extends(ForaDbModel, odm.DatabaseModel);

    exports.ForaModel = ForaModel;
    exports.ForaDbModel = ForaDbModel;

})();
