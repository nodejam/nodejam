ForaTypeUtilsBase = require('./foratypeutils-base').ForaTypeUtilsBase

class ForaTypeUtils extends ForaTypeUtilsBase


    addTrustedUserTypes: (ctor, baseTypeName, dir, definitions) =>*
        typeDef = if typeof ctor.typeDefinition is "function" then ctor.typeDefinition() else ctor.typeDefinition

        modules = require('/js/extensions/models')
        matches = (m for m in modules when new RegExp("^/js/extensions/#{dir}/").test m)

        for m in matches
            parts = m.split('/')
            typeName = parts[4]
            version = parts[5]
            ext = require("/js/extensions/#{dir}/#{typeName}/#{version}/model")
            definitions["#{dir}/#{typeName}/#{version}"] = @mergeUserTypeDefinition ext, ctor, baseTypeName, dir, typeName, version, typeDef

        return
        
        
module.exports = ForaTypeUtils
