
class ExtensionLoader

    constructor: (@trustedExtensionPath, @userExtensionPath) ->
        @trustedExtensionCache = []
        
        
    
    loadExtension: (extension) =>
        if extension.indexOf('/') is -1
            @loadTrustedExtension extension
        else
            @loadUserExtension extension
            
            
            
            
    loadTrustedExtension: (extension) =>
        



    loadUserExtension: (extension) =>
        #load external process here...
        #Sandboxen: 1) Node VM (run in this context), 2) Process 3) LX Container 4) VM (not now)


exports.ExtensionLoader = ExtensionLoader
