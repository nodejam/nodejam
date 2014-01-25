TypeUtils = require('../lib/data/typeutils').TypeUtils

class ForaTypeUtils extends TypeUtils

    getCacheItems: =>*
        definitions = {}
        
        for defs in [yield @getModelTypeDefinitions(), yield @getTrustedPostExtensions()]
            for name, def of defs
                definitions[name] ?= def    
        
        return definitions
        
    
    
    getModelTypeDefinitions: =>*
        #Get type definitions from models
        models = []

        fnAdd = (module) ->
            for name, model of module
                models.push model
                if model.childModels                    
                    fnAdd model.childModels

        for moduleName in ['./', './fields']
            fnAdd require moduleName

        
        definitions = {}
        
        for model in models            
            def = if typeof model.typeDefinition is "function" then model.typeDefinition() else model.typeDefinition
            def = @completeTypeDefinition(def, model)
            definitions[def.name] ?= def
        
        definitions
        
    
    
    getTrustedPostExtensions: =>*
        fs = require 'fs'
        path = require 'path'
        thunkify = require 'thunkify'
        readdir = thunkify fs.readdir
        stat = thunkify fs.stat
        
        getDirs = (dir) ->*
            dirs = []
            files = yield readdir dir
            for file, index in files
                filePath = "#{dir}/#{file}"
                entry = yield stat filePath
                if entry.isDirectory()
                    dirs.push(file)
            dirs            
        
        definitions = {}
        Post = require('./post').Post
        postTypeDef = if typeof Post.typeDefinition is "function" then Post.typeDefinition() else Post.typeDefinition
        
        for ext in yield getDirs path.join __dirname, '../extensions/posts'
            for version in yield getDirs path.join __dirname, '../extensions/posts', ext
                typeDefinition = require("../extensions/posts/#{ext}/#{version}/model")
                definitions["#{ext}/#{version}"] ?= typeDefinition
                typeDefinition.collection = postTypeDef.collection
                typeDefinition.trackChanges = postTypeDef.trackChanges
                typeDefinition.ctor = Post
                typeDefinition.trust = 'trusted'
                typeDefinition.version = version
                
                for k, v of postTypeDef.schema.properties
                    typeDefinition.schema.properties[k] = v
                
                for req in postTypeDef.schema.required
                    if typeDefinition.schema.required.indexOf(req) is -1
                        typeDefinition.schema.required.push req        

        definitions


        
        
    resolveDynamicTypeDefinition: (name) =>*
        for x, y of TypeUtils.typeCache
            console.log "Found " + x
        console.log "Missing " + JSON.stringify name
        
        
                        
exports.ForaTypeUtils = ForaTypeUtils
