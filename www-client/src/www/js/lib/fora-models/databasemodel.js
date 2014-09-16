(function() {
	"use strict";

	var __hasProp = {}.hasOwnProperty,
		__extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

	var _;

	var utils = require('./utils'),
		TypesUtil = require('./types-util'),
		typesUtil = new TypesUtil(),
		BaseModel = require('./basemodel'),
		ValidationError = require('./validation-error');


	//Constructor
	var DatabaseModel = function (params) {
		BaseModel.apply(this, arguments);
	};
	DatabaseModel.prototype = Object.create(BaseModel.prototype);
	DatabaseModel.prototype.constructor = DatabaseModel;
	__extends(DatabaseModel, BaseModel);

	module.exports = DatabaseModel;

})();
