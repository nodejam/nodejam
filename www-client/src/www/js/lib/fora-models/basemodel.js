(function() {
	"use strict";

	var dataUtils = require('fora-data-utils');
	var Validator = require('fora-validator');


	var BaseModel = function(params) {
		dataUtils.extend(this, params);
	};


	/*
		Rationale:
		One might think why anyone would call this method, when they can directly invoke typesService.getTypeDefinition(name)
		That involves a lookup, which we try to avoid by caching in __typeDefinition.
	*/
	BaseModel.getTypeDefinition = function*(typesService) {
		if (!this.__typeDefinition) {
			this.__typeDefinition = yield* typesService.getTypeDefinition(this.typeDefinition.name);
			if (!this.__typeDefinition)
				throw new Error("Unable to load type definition");
		}
		return this.__typeDefinition;
	};


	BaseModel.getLimit = function(limit, _default, max) {
		var result;
		result = _default;
		if (limit) {
			result = limit;
			if (result > max) {
				result = max;
			}
		}
		return result;
	};


	BaseModel.prototype.validate = function*(typesService) {
		var typeDefinition = yield* this.getTypeDefinition(typesService);
		var validator = new Validator(typesService);
		return yield* validator.validate(this, typeDefinition);
	};


	BaseModel.prototype.validateField = function*(value, fieldName, typeDefinition, typesService) {
		typeDefinition = yield* this.getTypeDefinition(typesService);
		var validator = new Validator(typesService);
		return yield* validator.validateField(this, value, fieldName, typeDefinition);
	};


	BaseModel.prototype.getTypeDefinition = function*(typesService) {
		return yield* this.constructor.getTypeDefinition(typesService);
	};


	BaseModel.prototype.toJSON = function() {
		var k, result, v;
		result = {};
		for (k in this) {
			v = this[k];
			if (!/^__/.test(k)) {
				result[k] = v;
			}
		}
		return result;
	};


	module.exports = BaseModel;

})();
