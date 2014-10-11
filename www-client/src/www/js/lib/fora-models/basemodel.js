(function() {
	"use strict";

	var dataUtils = require('fora-data-utils');
	var Validator = require('fora-validator');


	var BaseModel = function(params) {
		dataUtils.extend(this, params);
	};


	BaseModel.getTypeDefinition = function*(typesService) {
		if (!this.__typeDefinition) {
			this.__typeDefinition = yield* typesService.getTypeDefinition(this.typeDefinition.name);
			if (!this.__typeDefinition)
				throw new Error("Unable to load type definition");
		}
		return this.__typeDefinition;
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
		var typeDef = yield* this.constructor.getTypeDefinition(typesService);
		return typeDef.discriminator ? (yield* typeDef.discriminator(this, typesService)) : typeDef;
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
