(function() {
    "use strict";

    /*
        RequestParser Service
        A safe wrapper around the request to hide access to query, params and body.
        This allows us to sanitize those fields when requested.
    */

    var validator = require('validator'),
        sanitizer = require('sanitizer'),
        multipart = require('co-multipart'),
        body = require('co-body');

    var getParser = function(typesService) {

        var RequestParser = function(context) {
            this.context = context;
        };


        RequestParser.prototype.body = function*(name, def) {
            def = def || { type: "string" };

            if (!this.initted) {
                this.rawBody = yield body(this.context);
                this.initted = true;
            }

            if (typeof(def) === "string")
                def = { type: def };

            var value = this.rawBody[name];

            if (value)
                return this.parseSimpleType(value, name, def);

        };



        RequestParser.prototype.files = function*() {
            return (yield* multipart(this.context)).files;
        };



        RequestParser.prototype.map = function*(target, whitelist, options, parents) {
            options = options || { overwrite: true };
            parents = parents || [];

            whitelist = whitelist.map(function(e) {
                return e.split('_');
            });

            return yield* this.map_impl(target, whitelist, options, parents);

        };



        RequestParser.prototype.map_impl = function*(target, whitelist, options, parents) {
            var typeDef = yield* target.getTypeDefinition();

            for (var fieldName in typeDef.schema.properties) {
                var def = typeDef.schema.properties[fieldName];
                var fieldWhiteList = whitelist.filter(function(e) { return e[0] === fieldName; });

                if (yield* this.setField(target, fieldName, def, typeDef, fieldWhiteList, options, parents))
                    changed = true;
            }
            return changed;
        };



        RequestParser.prototype.setField = function*(obj, fieldName, def, typeDef, whitelist, options, parents) {
            if (typesService.isPrimitiveType(def.type)) {
                if (def.type !== 'array') {
                    if (whitelist[0] && whitelist[0][0] === fieldName)
                        return yield* this.setSimpleType(obj, fieldName, def, typeDef, whitelist, options, parents);
                } else {
                    return yield* this.setArray(obj, fieldName, def, typeDef, whitelist, options, parents);
                }
            } else {
                return yield* this.setCustomType(obj, fieldName, def, typeDef, whitelist, options, parents);
            }
        };


        //eg: name: "jeswin", age: 33
        RequestParser.prototype.setSimpleType = function*(obj, fieldName, def, typeDef, whitelist, options, parents) {
            var formField = parents.concat(fieldName).join('_');
            var val = yield* this.body(formField);
            if (val) {
                var result = this.parseSimpleType(val, fieldName, def, typeDef);
                if(!(obj instanceof Array)) {
                    if (options.overwrite)
                        obj[fieldName] = result;
                    else
                        obj[fieldName] = obj[fieldName] || result;
                    changed = true;
                } else {
                    obj.push(result);
                    changed = true;
                }
            }
            return changed;
        };



        /*
            Two possibilities
            #1. Array of primitives (eg: customerids_1: 13, customerids_2: 44, or as CSV like customerids: "1,54,66,224")
            #2. Array of objects (eg: customers_1_name: "jeswin", customers_1_age: "33")
        */
        RequestParser.prototype.setArray = function*(obj, fieldName, def, typeDef, whitelist, options, parents) {
            if (typeDef && typeDef.mapping && typeDef.mapping[fieldName]) {
                if (def.items.type !== 'array') {
                    if (whitelist.indexOf(fieldName) !== -1) {
                        var formField = parents.concat(fieldName).join('_');
                        var val = yield* this.body(formField);
                        var items = val.split(',');
                        items.forEach(function(i) {
                            obj[fieldName].push(this.parseSimpleType(val, fieldName + "[]", def.items, def));
                            changed = true;
                        });
                    }
                }
                else
                    throw new Error("Cannot map array of arrays");
            } else {
                parents.push(fieldName);

                var counter = 1;
                var newArray = obj[fieldName] || [];

                while(true) {
                    if (yield* this.setField(newArray, counter, def.items, def, whitelist, options, parents)) {
                        counter++;
                        obj[fieldName] = obj[fieldName] || newArray;
                        changed = true;
                    } else {
                        break;
                    }
                }

                parents.pop();
            }

            return changed;
        };



        RequestParser.prototype.setCustomType = function*(obj, fieldName, def, typeDef, whitelist, options, parents) {
            var changed;

            whitelist = whitelist.slice(1);

            parents.push(fieldName);
            if (def.typeDefinition && def.typeDefinition.ctor) {
                var newObj = new def.typeDefinition.ctor();
                changed = yield* this.map_impl(newObj, whitelist, options, parents);
                if (changed) {
                    if (!(obj instanceof Array))
                        obj[fieldName] = newObj;
                    else
                        obj.push(newObj);
                }
            }
            parents.pop();

            return changed;
        };



        RequestParser.prototype.parseSimpleType = function(val, fieldName, def, typeDef) {
            if (val) {
                switch(def.type) {
                    case "integer":
                        return parseInt(val);
                    case "number":
                        return parseFloat(val);
                    case "string":
                        return (typeDef && typeDef.htmlFields && typeDef.htmlFields.indexOf(fieldName) !== -1) ?
                            sanitizer.sanitize(sanitizer.unescapeEntities(val)) : sanitizer.escape(val);
                    case "boolean":
                        return val === "true";
                    default:
                        throw new Error(def.type + " " + fieldName + " is not a primitive type or is an array. Cannot parse.");
                }
            }
        };

        return RequestParser;

    };


    module.exports = getParser;

})();
