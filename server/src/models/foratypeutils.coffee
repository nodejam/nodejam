ForaTypeUtilsBase = require('./foratypeutils-base').ForaTypeUtilsBase
conf = require('../conf')
fs = require 'fs'
path = require 'path'
thunkify = require 'thunkify'
readdir = thunkify fs.readdir
stat = thunkify fs.stat
readfile = thunkify fs.readFile


class ForaTypeUtils extends ForaTypeUtilsBase



    addTrustedUserTypes: (ctor, baseTypeName, dir, definitions) =>*
        extensionsDir = require("path").resolve(__dirname, '../extensions')
        typeDef = if typeof ctor.typeDefinition is "function" then ctor.typeDefinition() else ctor.typeDefinition
        
        for typeName in yield @getUserTypeDirectories path.join extensionsDir, dir
            for version in yield @getUserTypeDirectories path.join extensionsDir, dir, typeName
                ext = require(path.join extensionsDir, dir, typeName, version, 'model')
                definitions["#{dir}/#{typeName}/#{version}"] = @mergeUserTypeDefinition ext, ctor, baseTypeName, dir, typeName, version, typeDef
        return



    getUserTypeDirectories: (dir) =>*
        dirs = []
        files = yield readdir dir
        for file, index in files
            filePath = "#{dir}/#{file}"
            entry = yield stat filePath
            if entry.isDirectory()
                dirs.push(file)
        dirs      

        
        
        
module.exports = ForaTypeUtils
