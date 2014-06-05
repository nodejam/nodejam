#neat trick via http://oranlooney.com/functional-javascript
__Clone = ->
clone = (obj) ->
    __Clone.prototype = obj
    new __Clone


deepCloneObject = (obj) ->
    if (obj is null) or (typeof(obj) isnt 'object')
        obj
    else
        temp = {}

        for key, value of obj
            temp[key] = deepCloneObject(value)
        temp
    

extend = (target, source, fnCanCopy) ->
    for key, val of source
        if (not target.hasOwnProperty(key)) and ((not fnCanCopy) or fnCanCopy(key))
            target[key] = val
    target
    

uniqueId = (length=24) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length
   


log = (msg) ->
    console.log msg

    

exports.clone = clone
exports.deepCloneObject = deepCloneObject
exports.extend = extend
exports.uniqueId = uniqueId
exports.log = log
