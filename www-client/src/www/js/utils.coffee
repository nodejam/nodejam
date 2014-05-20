#Generate a random identifier
uniqueId = (length = 16) ->
  id = ""
  id += Math.random().toString(36).substr(2) while id.length < length
  id.substr 0, length



flatten = (obj, seperator = "_", prefixes = [], result = {}) ->    
    if typeof obj is 'object'
        for k, v of obj
            if typeof v is 'object'
                prefixes.push k
                if v instanceof Array
                    counter = 1
                    for item in v
                        prefixes.push counter
                        window.Fora.Utils.flatten item, seperator, prefixes, result
                        prefixes.pop()
                        counter++

                else if v instanceof Date
                    result[prefixes.join(seperator)] = v
                    
                else if typeof v isnt 'function'
                    window.Fora.Utils.flatten v, seperator, prefixes, result
                prefixes.pop()
            else
                result[prefixes.concat(k).join(seperator)] = v
    else
        if not prefixes.length
            throw new Error "Invalid object"    
        
        result[prefixes.join(seperator)] = obj
     
    return result  
        
    
#get params by parsing the url. Decaf. 
`
getUrlParams = function (name) {
    name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
        results = regex.exec(location.search);
    return results == null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
}
`    

module.exports = {
    uniqueId,
    flatten,
    getUrlParams
}
