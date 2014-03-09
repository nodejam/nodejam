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
  

fixUrl = (url) ->
    if /http:\/\//.test(url)
        url    
    else
        "http://#{url}"        


log = (msg) ->
    console.log msg
    
    
getHashCode = (str) ->
    hash = 0
    if str.length isnt 0
        for i in [0...str.length] by 1
            char = str.charCodeAt(i)
            hash = ((hash << 5) - hash) + char
            hash = hash & hash
    Math.abs hash
    
        
printError = (err) ->
    if err
        log err.stack ? 'There is no stack trace.'
        if err.details
            log err.details
    else
        log 'Error is null or undefined.'


printStack = ->
    err = new Error
    log err.stack
    
    

exports.clone = clone
exports.deepCloneObject = deepCloneObject
exports.extend = extend
exports.uniqueId = uniqueId
exports.fixUrl = fixUrl
exports.log = log
exports.getHashCode = getHashCode
exports.printError = printError
exports.printStack = printStack
