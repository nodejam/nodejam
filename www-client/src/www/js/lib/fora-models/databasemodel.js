(function() {
	"use strict";

	var __hasProp = {}.hasOwnProperty,
		__extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } };

	var _;

	var BaseModel = require('./basemodel');

	//Constructor
	var DatabaseModel = function (params) {
		BaseModel.call(this, params);
	};

	DatabaseModel.prototype = Object.create(BaseModel.prototype);
	DatabaseModel.prototype.constructor = DatabaseModel;
	__extends(DatabaseModel, BaseModel);

	module.exports = DatabaseModel;

})();
