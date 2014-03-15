thunkify = require 'thunkify'
fs = require 'fs'
BaseModel = require '../lib/data/basemodel'
DatabaseModel = require '../lib/data/databasemodel'
ForaTypeUtils = require('./foratypeutils').ForaTypeUtils
typeUtils = new ForaTypeUtils()
                                        
class ForaModel extends BaseModel
    
    @getTypeUtils: ->
        typeUtils



class ForaDbModel extends DatabaseModel

    @getTypeUtils: ->
        typeUtils



class ForaExtensibleModel extends DatabaseModel

    @getTypeUtils: ->
        typeUtils


    @getExtensions: (typeDef) =>*

        if not @builtinExtensionCache
            @builtinExtensionCache = {}
    
        parent = typeDef.identifier.split('/')[0]
        
        if parent isnt 'posts' and parent isnt 'forums'
            throw new Error "User defined type must be a post or a forum, parent was #{parent}"
        
        switch typeDef.extensionType
            when 'builtin'
                if not @builtinExtensionCache[typeDef.identifier]

                    #We redefine the require() function inside the extension                    
                    modules = {
                        "react": require("react"),
                        "widgets": require("../common/widgets")
                    }
                    requireProxy = (name) -> modules[name]
                    
                    @builtinExtensionCache[typeDef.identifier] = {
                        model: require("../type-definitions/#{typeDef.identifier}/model")(requireProxy),
                        templates: {}
                    }

                    files = yield thunkify(fs.readdir).call fs, "../type-definitions/#{typeDef.identifier}/templates"
                    for file in files
                        template = file.match /[a-z]*/
                        instance = require("../type-definitions/#{typeDef.identifier}/templates/#{template}") 
                        @builtinExtensionCache[typeDef.identifier].templates[template] = instance requireProxy

                @builtinExtensionCache[typeDef.identifier]
            else
                throw new Error "Unsupported extension type"



exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
exports.ForaExtensibleModel = ForaExtensibleModel


