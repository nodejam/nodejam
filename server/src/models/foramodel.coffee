thunkify = require 'thunkify'
fs = require 'fs'
BaseModel = require '../lib/data/basemodel'
DatabaseModel = require '../lib/data/databasemodel'
typeUtils = require('./foratypeutils').typeUtils
                                        
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



    @getUserDefinedType: (typeDef) =>*
        switch typeDef.extensionType
            when 'builtin'
                if not @builtinExtensionCache[typeDef.name]
                    dir = switch typeDef.type
                        when 'post'
                            'posts'
                        when 'forum'
                            'forums'

                    @builtinExtensionCache[typeDef.name] = {
                        model: require("../type-definitions/#{dir}/#{typeDef.name}/model"),
                        templates: {}
                    }
                    
                    files = yield thunkify(fs.readdir).call fs, "../type-definitions/#{dir}/#{typeDef.name}/templates"
                    for file in files
                        template = file.match /[a-z]*/
                        @builtinExtensionCache[typeDef.name].templates[template] = require("../type-definitions/#{dir}/#{typeDef.name}/templates/#{template}")

                @builtinExtensionCache[typeDef.name]
            else
                throw new Error "Unsupported extension type"



exports.ForaModel = ForaModel
exports.ForaDbModel = ForaDbModel
exports.ForaExtensibleModel = ForaExtensibleModel


