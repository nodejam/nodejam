(function() {
	"use strict";
	
	var __Clone = function() {};
	var clone = function(obj) {
		__Clone.prototype = obj;
		return new __Clone();
	};


	var deepCloneObject = function(obj) {
		var key, temp, value;
		if ((obj === null) || (typeof obj !== 'object')) {
			return obj;
		} else {
			temp = {};
			for (key in obj) {
				value = obj[key];
				temp[key] = deepCloneObject(value);
			}
			return temp;
		}
	};


	var extend = function(target, source, fnCanCopy) {
		var key, val;
		for (key in source) {
			val = source[key];
			if ((!target.hasOwnProperty(key)) && ((!fnCanCopy) || fnCanCopy(key))) {
				target[key] = val;
			}
		}
		return target;
	};


	var uniqueId = function(length) {
		var id;
		if (!length) {
			length = 24;
		}
		id = "";
		while (id.length < length) {
			id += Math.random().toString(36).substr(2);
		}
		return id.substr(0, length);
	};


	var log = function(msg) {
		return console.log(msg);
	};


	module.exports = {
		clone: clone,
		deepCloneObject: deepCloneObject,
		extend: extend,
		uniqueId: uniqueId,
		log: log
	};

})();
