(function () {
    "use strict";

    var argv = require('optimist').argv;

    var Mapper = function (typesService) {
        this.typesService = typesService;
    };

    Mapper.prototype.getMappableFields = function *(typeDef, acc, prefix) {
        var _, field, def;

        acc = acc || [];
        prefix = prefix || [];

        for (field in typeDef.schema.properties) {
            def = typeDef.schema.properties[field];

            if (typeDef.inheritedProperties && typeDef.inheritedProperties.indexOf(field) === -1) {
                if (this.typesService.isPrimitiveType(def.type)) {
                    if (def.type === 'array' && this.typesService.isCustomType(def.items.type)) {
                        prefix.push(field);
                        _ = yield* this.getMappableFields(def.items.typeDefinition, acc, prefix);
                        prefix.pop(field);
                    }
                    else {
                        acc.push(prefix.concat(field).join('_'));
                    }
                } else {
                    if(this.typesService.isCustomType(def.type)) {
                        prefix.push(field);
                        _ = yield* this.getMappableFields(def.typeDefinition, acc, prefix);
                        prefix.pop(field);
                    }
                }
            }
        }

        return acc;
    };

    module.exports = Mapper;

})();
