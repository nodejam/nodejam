class ApplicationCache

    constructor: () ->
        @items = {}
        

    add: (key, value) =>
        @items[key] = value
        
        
    remove: (key) =>
        delete @items[key]
        
exports.ApplicationCache = ApplicationCache
