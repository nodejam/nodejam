uniqueId = (length=24) ->
    id = ""
    id += Math.random().toString(36).substr(2) while id.length < length
    id.substr 0, length


module.exports = {
    uniqueId
}
