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

    @builtinExtensionCache = {}
    

    @getTypeUtils: ->
        typeUtils


    @getExtensions: (typeDef) =>*
        [parent, name, version] = typeDef.identifier.split '/'
        
        if parent isnt 'posts' and parent isnt 'forums'
            throw new Error "User defined type must be a post or a forum, parent was #{parent}"
        
        switch typeDef.extensionType
            when 'builtin'
                if not @builtinExtensionCache[typeDef.name]

                    @builtinExtensionCache[typeDef.name] = {
                        model: require("../type-definitions/#{parent}/#{name}/#{version}/model"),
                        templates: {}
                    }
                    
                    files = yield thunkify(fs.readdir).call fs, "../type-definitions/#{parent}/#{name}/#{version}/templates"
                    for file in files
                        template = file.match /[a-z]*/
                        @builtinExtensionCache[typeDef.name].templates[template] = require("../type-definitions/#{parent}/#{name}/#{version}/templates/#{template}")

                @builtinExtensionCache[typeDef.name]
            else
                throw new Error "Unsupported extension type"



exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
exports.ForaExtensibleModel = ForaExtensibleModel


