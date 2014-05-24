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
    

getHashCode = (str) ->
    hash = 0
    if str.length isnt 0
        for i in [0...str.length] by 1
            char = str.charCodeAt(i)
            hash = ((hash << 5) - hash) + char
            hash = hash & hash
    Math.abs hash
    
    
module.exports = {
    clone,
    deepCloneObject,
    extend,
    getHashCode
}
